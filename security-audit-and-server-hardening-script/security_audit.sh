#!/bin/bash

LOGFILE="security_audit.log"
CONFIGFILE="security_config.conf"
EMAIL_ALERTS="admin@example.com"

# Function to log messages
log() {
    echo "$1" | tee -a $LOGFILE
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# User and Group Audits
audit_users() {
    log "Auditing Users and Groups:"
    awk -F: '($3 == 0) {print "Root user: " $1}' /etc/passwd | tee -a $LOGFILE
    log "Users without passwords:"
    awk -F: '($2 == "" ) {print $1}' /etc/shadow | tee -a $LOGFILE
}

# File and Directory Permissions
check_permissions() {
    log "Checking File and Directory Permissions:"

    # World-writable files
    log "World-writable files:"
    find / -type f -perm -o+w -exec ls -l {} \; 2>/dev/null | tee -a $LOGFILE

    # World-writable directories
    log "World-writable directories:"
    find / -type d -perm -o+w -exec ls -ld {} \; 2>/dev/null | tee -a $LOGFILE

    # SUID/SGID bits
    log "Files with SUID bits set:"
    find / -type f -perm -4000 -exec ls -l {} \; 2>/dev/null | tee -a $LOGFILE
    log "Files with SGID bits set:"
    find / -type f -perm -2000 -exec ls -l {} \; 2>/dev/null | tee -a $LOGFILE

    # Check .ssh directories and their permissions
    log "Checking .ssh directories and permissions:"
    find / -type d -name ".ssh" -exec ls -ld {} \; 2>/dev/null | tee -a $LOGFILE

    # Check permissions for .ssh directories
    log "Ensuring .ssh directories have secure permissions:"
    find / -type d -name ".ssh" -exec sh -c 'if [ $(stat -c "%a" {}) != "700" ]; then echo "{} permissions are insecure"; fi' \; 2>/dev/null | tee -a $LOGFILE

    log "Ensuring authorized_keys and id_rsa files have secure permissions:"
    find / -type f -name "authorized_keys" -exec sh -c 'if [ $(stat -c "%a" {}) != "600" ]; then echo "{} permissions are insecure"; fi' \; 2>/dev/null | tee -a $LOGFILE
    find / -type f -name "id_rsa" -exec sh -c 'if [ $(stat -c "%a" {}) != "600" ]; then echo "{} permissions are insecure"; fi' \; 2>/dev/null | tee -a $LOGFILE
}

# Service Audits
audit_services() {
    log "Auditing Running Services:"
    systemctl list-units --type=service --state=running 2>/dev/null | tee -a $LOGFILE
    log "Checking for insecure ports:"
    ss -tuln 2>/dev/null | tee -a $LOGFILE
}

# Firewall and Network Security
check_firewall() {
    log "Checking Firewall Configuration:"
    if command_exists iptables; then
        iptables -L 2>/dev/null | tee -a $LOGFILE
    fi
    if command_exists ufw; then
        ufw status verbose 2>/dev/null | tee -a $LOGFILE
    fi
}

# IP and Network Configuration Checks
check_ips() {
    log "Checking IP Configuration:"
    ip a | grep -oP 'inet \K[\d.]+' | while read ip; do
        [[ "$ip" =~ ^(10|172\.16|192\.168)\. ]] && echo "$ip is private" || echo "$ip is public"
    done | tee -a $LOGFILE
}

# Security Updates and Patching
check_updates() {
    log "Checking for Security Updates:"
    if command_exists apt-get; then
        apt-get update -q > /dev/null
        apt-get -s upgrade | grep -i security | tee -a $LOGFILE
    elif command_exists yum; then
        yum check-update --security | tee -a $LOGFILE
    else
        log "No compatible package manager found."
    fi
}

# Log Monitoring
log_monitoring() {
    log "Checking Recent Log Entries:"
    grep -i 'sshd\|failed' /var/log/auth.log | tail -n 20 | tee -a $LOGFILE
}

# Server Hardening Steps
harden_server() {
    log "Hardening Server Configuration:"

    # Backup and modify sshd_config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    systemctl restart sshd

    # Backup and modify sysctl.conf
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p

    # GRUB password setup (manual step required)
    log "GRUB password setup (manual):"
    grub-mkpasswd-pbkdf2 | tee -a $LOGFILE

    # Apply iptables rules
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables-save > /etc/iptables/rules.v4

    # Setup unattended-upgrades
    apt-get install -y unattended-upgrades
    dpkg-reconfigure --priority=low unattended-upgrades

    log "Server Hardening Complete."
}

# Custom Security Checks
custom_checks() {
    log "Performing Custom Security Checks:"
    # Placeholder for additional custom checks
    # Example: Check for specific files or configurations
    if [ -f "$CONFIGFILE" ]; then
        source $CONFIGFILE
        # Execute custom checks as defined in the configuration file
    fi
}

# Reporting and Alerting
send_alerts() {
    log "Sending alerts..."
    mail -s "Security Audit Report" $EMAIL_ALERTS < $LOGFILE
}

# Execute all functions
audit_users
check_permissions
audit_services
check_firewall
check_ips
check_updates
log_monitoring
harden_server
custom_checks
send_alerts

log "Security audit and hardening complete. Check $LOGFILE for details."

