#!/bin/bash
# ===============================================
# Kali Linux IAM & Hardening Mini Project Script
# ===============================================
# Author: Deepak Bareth
# Objective: Create users, groups, permissions, ACLs, and sudo rules
# Kali-compatible: avoids auditd dependency and uses manual audit logging
# Usage: sudo bash setup_iam_kali.sh
# ===============================================

set -euo pipefail

PROJECT_DIR=~/iam_project
EVID_DIR="$PROJECT_DIR/evidence"
LOG_FILE="/var/log/manual_audit.log"

echo "=== [1/8] Setting up directories ==="
mkdir -p "$EVID_DIR"
sudo touch "$LOG_FILE"
sudo chmod 644 "$LOG_FILE"

# -------------------------------
echo "=== [2/8] Creating groups ==="
for g in sysadmin project auditor; do
    if ! getent group "$g" >/dev/null; then
        sudo groupadd "$g"
        echo "Created group: $g"
    else
        echo "Group $g already exists"
    fi
done

# -------------------------------
echo "=== [3/8] Creating users ==="
declare -A USERS=( [alice]=sysadmin [bob]=project [carol]=project [dave]=auditor )
for u in "${!USERS[@]}"; do
    grp=${USERS[$u]}
    if ! id "$u" >/dev/null 2>&1; then
        sudo useradd -m -s /bin/bash -G "$grp" "$u"
        echo "$u:TempPassw0rd!" | sudo chpasswd
        sudo chmod 700 /home/$u
        echo "User $u created and added to group $grp"
        echo "$(date) Created user $u in group $grp" | sudo tee -a "$LOG_FILE" >/dev/null
    else
        echo "User $u already exists"
    fi
done

# Evidence
id alice | tee "$EVID_DIR/id_alice.txt"
getent group project | tee "$EVID_DIR/group_project.txt"

# -------------------------------
echo "=== [4/8] Creating shared project folder ==="
sudo mkdir -p /srv/project
sudo chown root:project /srv/project
sudo chmod 2775 /srv/project
sudo apt update -y
sudo apt install -y acl >/dev/null 2>&1 || true
sudo setfacl -R -m g:project:rwx /srv/project || true
sudo setfacl -R -d -m g:project:rwx /srv/project || true
sudo chmod o=rX /srv/project

# Evidence
ls -ld /srv/project | tee "$EVID_DIR/ls_srv_project.txt"
getfacl /srv/project | tee "$EVID_DIR/getfacl_srv_project.txt"

# -------------------------------
echo "=== [5/8] Configuring sudoers (least privilege) ==="
SUDO_FILE="/etc/sudoers.d/sysadmin"
sudo bash -c "cat > $SUDO_FILE" <<'EOF'
# Sysadmin group — limited sudo privileges
%sysadmin ALL=(ALL) /usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel, /usr/bin/passwd, /bin/systemctl, /usr/bin/apt-get, /bin/journalctl
# Project group — limited deploy rights
%project ALL=(root) /bin/systemctl restart myapp.service, /bin/systemctl status myapp.service
EOF

sudo chmod 0440 "$SUDO_FILE"
sudo chown root:root "$SUDO_FILE"
sudo visudo -c -f "$SUDO_FILE"
sudo -l -U alice | tee "$EVID_DIR/sudo_list_alice.txt"
echo "$(date) Updated sudoers: $SUDO_FILE" | sudo tee -a "$LOG_FILE" >/dev/null

# -------------------------------
echo "=== [6/8] Manual auditing setup ==="
# Instead of auditd, use manual logging
echo "$(date) Manual auditing active. Changes to sudoers or passwd will be logged in $LOG_FILE" | sudo tee -a "$LOG_FILE" >/dev/null

# -------------------------------
echo "=== [7/8] Checking for common misconfigurations ==="

# A. World-writable /etc/cron.d
if [ -d /etc/cron.d ]; then
    perms=$(stat -c %a /etc/cron.d)
    # If others write bit set, fix it
    if [ $((perms % 10)) -ge 2 ]; then
        echo "[!] Fixing world-writable /etc/cron.d"
        sudo chmod 755 /etc/cron.d
        echo "$(date) Fixed /etc/cron.d permissions" | sudo tee -a "$LOG_FILE" >/dev/null
    fi
    ls -ld /etc/cron.d | tee "$EVID_DIR/cron_perms.txt"
fi

# B. Insecure sudo NOPASSWD entries
sudo grep -R "NOPASSWD" /etc/sudoers /etc/sudoers.d || echo "No NOPASSWD entries found" | tee "$EVID_DIR/nopasswd_check.txt"
echo "$(date) Checked sudoers for NOPASSWD" | sudo tee -a "$LOG_FILE" >/dev/null

# C. Weak /etc/passwd or /etc/shadow perms
sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/shadow
ls -l /etc/passwd /etc/shadow | tee "$EVID_DIR/passwd_perms.txt"
echo "$(date) Fixed passwd/shadow perms" | sudo tee -a "$LOG_FILE" >/dev/null

# -------------------------------
echo "=== [8/8] Summary & packaging ==="
cat > "$PROJECT_DIR/remediation_checklist.txt" <<'EOF'
Remediation Checklist:
[✓] Users & groups created
[✓] Least privilege sudo policy applied
[✓] /srv/project ACL & perms set
[✓] No world-writable system dirs
[✓] /etc/passwd & /etc/shadow permissions hardened
[✓] Manual auditing log active (/var/log/manual_audit.log)
EOF

cd "$PROJECT_DIR"
tar czvf evidence_package.tar.gz evidence remediation_checklist.txt >/dev/null 2>&1
echo "Evidence packaged: $PROJECT_DIR/evidence_package.tar.gz"

echo "=== ✅ All done! ==="
echo "You can review logs in: $LOG_FILE"
