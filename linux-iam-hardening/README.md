# Linux IAM & Hardening — Mini Project
**Author:** Deepak Bareth 
**Institute:** Rungta College of Engineering  
**Course:** Ethical Hacking Project  
**Submission:** November 2025

## Objective
Design and implement a secure user/group and permission model on a Kali (Debian-based) system. Identify and fix typical misconfigurations, apply least-privilege sudo rules, configure shared folder ACLs, and enable basic auditing (manual) for the lab environment.

## Contents
- `setup_iam_kali.sh` — Automation script (Kali-compatible)
- `baseline_policy.txt` — One-page policy
- `remediation_checklist.txt` — Final checklist
- `docs/report.txt` — Detailed remediation report (plain text)
- `docs/slides_outline.txt` — Slide outline for presentation

## How to run
```bash
git clone <your-repo-url>
cd linux-iam-hardening
chmod +x setup_iam_kali.sh
sudo bash setup_iam_kali.sh
```

## What the script does
- Creates groups: `sysadmin`, `project`, `auditor`
- Creates users: `alice` (sysadmin), `bob`, `carol` (project), `dave` (auditor)
- Sets strict home directory permissions (700)
- Creates `/srv/project` with setgid and default ACLs for `project` group
- Deploys a least-privilege sudoers file under `/etc/sudoers.d/`
- Performs basic checks and fixes for common misconfigurations
- Uses `/var/log/manual_audit.log` for audit entries (auditd not required)

## Evidence
After running, review `~/iam_project/evidence/` for generated evidence files, and `/var/log/manual_audit.log` for manual audit entries.

## Notes for Submission
- Replace temporary passwords and change default users as needed before final evaluation.
- For production use, configure SSH keys and enable proper centralized logging/auditing.
