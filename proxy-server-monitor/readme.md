# System Monitoring Script

## Overview

This script provides a comprehensive system monitoring dashboard that can be customized to display various metrics such as CPU usage, memory usage, network statistics, disk usage, system load, active processes, and service statuses. The script is designed to run continuously and update its output every 5 seconds.

## Prerequisites

Before running the script, ensure that the following tools and utilities are installed on your system:

1. **`top`**: For retrieving CPU usage and system load information.
2. **`ps`**: For displaying process information.
3. **`free`**: For showing memory usage statistics.
4. **`df`**: For checking disk usage by mounted partitions.
5. **`ss`**: For network statistics and active connections.
6. **`netstat`**: For packet drop statistics.
7. **`awk`**: For processing and formatting text output.
8. **`bc`**: For performing arithmetic calculations (e.g., converting bytes to megabytes).
9. **`ip`**: For retrieving network interface information.
10. **`systemctl`**: For checking the status of services.

These tools are commonly available on most Unix-like systems. You can install missing tools using your package manager. For example:

- On Debian/Ubuntu-based systems:
  ```bash
  sudo apt-get install procps net-tools iproute2 awk bc
  ```

- On Red Hat/CentOS-based systems:
  ```bash
  sudo yum install procps-ng net-tools iproute awk bc
  ```

## Usage

The script supports command-line flags to display specific sections of the monitoring dashboard. You can also run the script without any flags to view all metrics.

### Running the Script

To run the script, use the following command:

```bash
./monitor.sh [options]
```

### Command-Line Options

- `-cpu`: Display CPU usage details.
- `-memory`: Display memory usage details.
- `-network`: Display network statistics.
- `-disk`: Display disk usage details.
- `-load`: Display system load and CPU usage breakdown.
- `-processes`: Display process statistics.
- `-services`: Display the status of essential services.
- `-top`: Display the top 10 most used applications by CPU and memory.
- (Default) If no flags are provided, all sections will be displayed.

### Examples

- **Display CPU Usage**:
  ```bash
  ./monitor.sh -cpu
  ```

- **Display Memory Usage**:
  ```bash
  ./monitor.sh -memory
  ```

- **Display Network Statistics**:
  ```bash
  ./monitor.sh -network
  ```

- **Display Disk Usage**:
  ```bash
  ./monitor.sh -disk
  ```

- **Display System Load and CPU Usage**:
  ```bash
  ./monitor.sh -load
  ```

- **Display Process Statistics**:
  ```bash
  ./monitor.sh -processes
  ```

- **Display Service Status**:
  ```bash
  ./monitor.sh -services
  ```

- **Display Top 10 Most Used Applications**:
  ```bash
  ./monitor.sh -top
  ```

- **Display All Metrics**:
  ```bash
  ./monitor.sh
  ```

## Download and Installation

You can download the script from the GitHub repository:

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/Irfan-Shaikh-99/SafeSquid-task.git
    ```

2. **Navigate to the Directory**:
    ```bash
    cd SafeSquid-task/proxy-server-monitor
    ```

3. **Ensure the Script is Executable**:
    ```bash
    chmod +x monitor.sh
    ```

4. **Run the Script**:
    ```bash
    ./monitor.sh
    ```
