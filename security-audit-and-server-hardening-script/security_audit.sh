#!/bin/bash

LOGFILE="security_audit.log"
CONFIGFILE="security_config.conf"

# Function to log messages
log() {
    echo "$1" | tee -a $LOGFILE
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Load configuration file if it exists
if [ -f "$CONFIGFILE" ]; then
    source "$CONFIGFILE"
else
    log "Configuration file $CONFIGFILE not found. Using default settings."
fi

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
    
    log "World-writable files:"
    find / -type f -perm -o+w -exec ls -l {} \; 2>/dev/null | tee -a $LOGFILE
    
    log "Checking .ssh directories:"
    find /home -maxdepth 2 -name ".ssh" -exec ls -ld {} \; | tee -a $LOGFILE
    
    log "Files with SUID/SGID bits set:"
    find / -perm /6000 -type f -exec ls -ld {} \; 2>/dev/null | tee -a $LOGFILE
}

# Auditing Running Services
audit_services() {
    log "Auditing Running Services:"
    systemctl list-units --type=service --state=running | tee -a $LOGFILE
}

# Checking Firewall and Network Security
check_firewall() {
    log "Checking Firewall:"
    iptables -L | tee -a $LOGFILE
    ss -tuln | tee -a $LOGFILE
}

# IP and Network Configuration Checks
check_ips() {
    log "IP Configuration:"
    ip a | grep -oP 'inet \K[\d.]+' | while read ip; do
        [[ "$ip" =~ ^(10|172\.16|192\.168)\. ]] && echo "$ip is private" || echo "$ip is public"
    done | tee -a $LOGFILE
}

# Security Updates and Patching
check_updates() {
    log "Checking for Updates:"
    apt-get update -q > /dev/null
    apt-get -s upgrade | grep -i security | tee -a $LOGFILE
}

# Log Monitoring
log_monitoring() {
    log "Monitoring Logs:"
    grep "Failed password" /var/log/auth.log | tail -n 10 | tee -a $LOGFILE
}

# Server Hardening
harden_server() {
    log "Hardening Server:"
    # SSH Configuration
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    systemctl restart sshd

    # Disable IPv6 if not required
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p

    # Set GRUB password (manual step required)
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

# Execute all functions
audit_users
check_permissions
audit_services
check_firewall
check_ips
check_updates
log_monitoring
harden_server

log "Security audit and hardening complete. Check $LOGFILE for details."
