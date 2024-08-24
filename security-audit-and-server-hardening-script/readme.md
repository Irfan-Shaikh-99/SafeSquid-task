# Security Audit and Hardening Script

## Overview

This script performs a comprehensive security audit and hardening of Linux servers. It automates the process of checking user and group configurations, file permissions, running services, firewall settings, IP configurations, and more. The script also includes server hardening measures and provides modular functionality for easy adaptation and extension.

## Features

- **User and Group Audits**: Lists users, checks for root privileges, and identifies users without passwords.
- **File and Directory Permissions**: Scans for world-writable files, checks `.ssh` directories, and identifies files with SUID/SGID bits.
- **Service Audits**: Lists running services and checks for unnecessary or unauthorized services.
- **Firewall and Network Security**: Verifies firewall configuration and reports open ports.
- **IP Configuration**: Identifies public vs. private IPs and checks IP configuration.
- **Security Updates and Patching**: Checks for available security updates and ensures regular updates.
- **Log Monitoring**: Monitors logs for suspicious entries.
- **Server Hardening**: Implements SSH key-based authentication, disables IPv6, secures GRUB, and configures iptables and unattended-upgrades.
- **Custom Security Checks**: Allows for extension with custom checks via a configuration file.

## Configuration

### Configuration File

The script can use a configuration file to customize its behavior. The configuration file should be named `security_config.conf` and placed in the same directory as the script.

**Example Configuration File (`security_config.conf`)**:
```bash
# Define custom settings here

# Paths to check for permissions or other audits
CHECK_PATHS=("/etc" "/var/www" "/home/user")

# Example users or services to include/exclude
EXCLUDED_USERS=("user1" "user2")
REQUIRED_SERVICES=("sshd" "iptables")

# Enable or disable specific checks
ENABLE_SSH_CHECK=true
ENABLE_FIREWALL_CHECK=true
```

### How to Use the Configuration File

1. **Create the Configuration File**: Create a file named `security_config.conf` in the same directory as `security_audit.sh`.

2. **Define Your Custom Settings**: Add any desired settings or paths to `security_config.conf`.

3. **Run the Script**: Execute the script from the directory where both files are located:
    ```bash
    sudo ./security_audit.sh
    ```

4. **Script Behavior**: The script will automatically source `security_config.conf` if it is present. If the configuration file is not found, the script will use default settings.

## Download and Installation

You can download the script and configuration file from the GitHub repository:

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/Irfan-Shaikh-99/SafeSquid-task.git
    ```

2. **Navigate to the Directory**:
    ```bash
    cd SafeSquid-task
    ```

3. **Ensure the Script is Executable**:
    ```bash
    chmod +x security_audit.sh
    ```

4. **Run the Script**:
    ```bash
    sudo ./security_audit.sh
    ```

## Dependencies

- `bash`
- `awk`
- `find`
- `systemctl`
- `iptables`
- `ss`
- `grep`
- `apt-get` (for updates and package management)
- `grub-mkpasswd-pbkdf2` (for GRUB password setup)
- `unattended-upgrades` (for automatic updates)
