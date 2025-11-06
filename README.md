# linux-iam-hardening
 linux-iam-hardening
# 🔐 Linux IAM & Hardening — Ethical Hacking Mini Project  
**Author:** Deepak Bareth
**Institute:** Rungta College of Engineering  
**Department:** Computer Science & Engineering  
**Course:** Ethical Hacking Project  
**Submission:** November 2025  

---

## 🧩 Project Overview  
This project demonstrates the implementation #of a **secure IAM (Identity & Access Management)** model and basic **system hardening** techniques on a **Kali Linux (Debian-based)** virtual machine.  

The objective is to design a secure user/group/permission policy, fix common misconfigurations, and document all security improvements for auditing and compliance.

---

## 🎯 Objectives  
- Create users and groups with **least privilege access**  
- Apply **POSIX permissions + ACLs** on shared folders  
- Configure **sudoers** file with specific command-level control  
- Detect and fix **common misconfigurations**  
- Maintain **audit logs** for privileged changes  
- Produce a full **remediation report and checklist**

---

## ⚙️ Environment & Tools  
| Component | Description |
|------------|-------------|
| **OS** | Kali Linux (Debian-based) |
| **Tools Used** | `sudo`, `useradd`, `groupadd`, `chmod`, `chown`, `getfacl`, `visudo`, `tar`, `bash` |
| **Privileges** | Sudo required |
| **Audit** | Manual logging (`/var/log/manual_audit.log`) |

---

## 🧠 System Design
### 👥 Roles & Groups
| Role | Group | Users | Access Level |
|------|--------|--------|---------------|
| **Sysadmin** | `sysadmin` | `alice` | Limited sudo (system/user management) |
| **Developer** | `project` | `bob`, `carol` | Full read/write to `/srv/project` |
| **Auditor** | `auditor` | `dave` | Read-only access |

---

## 🛠️ Implementation
### Step 1: Clone and Run  
```bash
git clone https://github.com/<your-username>/linux-iam-hardening.git
cd linux-iam-hardening
chmod +x setup_iam_kali.sh
sudo ./setup_iam_kali.sh

This script will:
✅ Create groups (sysadmin, project, auditor)
✅ Create users (alice, bob, carol, dave)
✅ Apply ACLs and setgid on /srv/project
✅ Configure least-privilege sudoers entries
✅ Detect & fix 3 common security misconfigurations
✅ Log all actions to /var/log/manual_audit.log
✅ Generate evidence in ~/iam_project/evidence/

🧾 Evidence Collected

User & group listings (id, getent)

Folder ACLs (getfacl /srv/project)

Sudo privileges (sudo -l)

Permission fixes (ls -l /etc/passwd /etc/shadow)

Manual audit logs (/var/log/manual_audit.log)

| Issue                          | Description                        | Fix                                              |
| ------------------------------ | ---------------------------------- | ------------------------------------------------ |
| World-writable `/etc/cron.d`   | Allowed any user to edit cron jobs | `chmod 755 /etc/cron.d`                          |
| Unrestricted `NOPASSWD` sudo   | Allowed root without password      | Removed & replaced with command whitelisting     |
| Weak `/etc/passwd` permissions | World-readable sensitive data      | `chmod 644 /etc/passwd && chmod 600 /etc/shadow` |

| File                                             | Description                      |
| ------------------------------------------------ | -------------------------------- |
| `setup_iam_kali.sh`                              | Main automation script           |
| `baseline_policy.txt`                            | Role-based access control policy |
| `remediation_checklist.txt`                      | Security checklist               |
| `docs/report.txt`                                | Detailed report (plain text)     |
| `docs/slides_outline.txt`                        | Slide content for presentation   |
| `Linux_IAM_Hardening_Report_Lakshya_Borikar.pdf` | Final report (formatted PDF)     |

🧰 Recommended Improvements

Replace temporary passwords with SSH keys

Enable auditd for enterprise environments

Centralize logs to a SIEM platform

Review and update sudo rules monthly

👨‍💻 Author

Lakshya Borikar
B.Tech — Computer Science & Engineering
Rungta College of Engineering
📅 Submitted: November 2025
📚 Course: Ethical Hacking Project

📜 License

This project is created for educational purposes only.
You may freely fork, reuse, and modify it for learning or demonstration.
