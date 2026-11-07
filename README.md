# Network Connectivity Checker

A Bash-based network troubleshooting tool designed to check network connectivity and identify common connectivity issues.

This project was developed as part of my Site Reliability Engineering (SRE) learning journey.

## Project Overview

The Network Connectivity Checker performs a series of checks against a target host to help identify network connectivity problems.

It checks:

- **DNS Resolution:** Verifies whether the hostname can be resolved to an IP address (IPv4 or IPv6).
- **ICMP Connectivity:** Uses ping to check whether the target responds to ICMP requests.
- **TCP Connectivity:** Checks whether a specified TCP port is reachable.
- **HTTPS Connectivity:** Uses curl to verify whether the target responds to an HTTPS request.

At the end, the script generates a health summary indicating the overall connectivity status.

## Technologies Used

- Bash
- Linux / Ubuntu
- WSL (Windows Subsystem for Linux)
- Git
- GitHub
- Linux networking utilities: `getent`, `ping`, `nc`, and `curl`

## Prerequisites

Make sure the following tools are installed:

- `getent`
- `ping`
- `netcat` (`nc`)
- `curl`

## How to Use

Clone the repository:

```bash
git clone https://github.com/MarinaAlmeida20/network-connectivity-checker.git
```

Navigate to the project directory:

```bash
cd network-connectivity-checker
```

Make the script executable:

```bash
chmod +x network-check.sh
```

Run the script using the default target (`google.com`) and port (`443`):

```bash
./network-check.sh
```

You can also specify a custom hostname and port:

```bash
./network-check.sh example.com 443
```

## Health Status

The script returns one of three overall statuses:

| Status | Description |
|---|---|
| HEALTHY | DNS, TCP and HTTPS checks succeeded. |
| DEGRADED | DNS and TCP checks succeeded, but HTTPS failed. |
| UNHEALTHY | DNS resolution or TCP connectivity failed. |

**Note:** ICMP connectivity is informational and does not determine the overall health status. Some servers and networks block ping requests while still allowing normal application traffic.

## Exit Codes

| Exit Code | Meaning |
|---|---|
| 0 | HEALTHY |
| 1 | DEGRADED |
| 2 | UNHEALTHY |

Exit codes allow other scripts and automation tools to identify the result programmatically.

## Example Scenarios Tested

| Target | Port | Expected Result |
|---|---:|---|
| google.com | 443 | HEALTHY |
| example.com | 443 | HEALTHY |
| google.com | 81 | UNHEALTHY |
| does-not-exist.invalid | 443 | UNHEALTHY |

## What I Learned

Through this project, I practised:

- Network troubleshooting fundamentals.
- DNS resolution and IP address lookup.
- ICMP and TCP connectivity checks.
- HTTPS connectivity testing.
- Bash scripting and functions.
- Conditional logic and exit codes.
- Git version control and GitHub repository management.

## Future Improvements

Potential improvements include:

- Support for custom HTTPS URLs.
- Configurable connection timeouts.
- Logging results to a file.
- Monitoring multiple hosts.
- Integration with monitoring and alerting systems.

## Author

Created as part of my SRE learning journey.
