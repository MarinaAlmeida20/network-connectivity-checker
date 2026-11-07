#!/usr/bin/env bash

# Network Connectivity Checker
# A simple network troubleshooting tool for SRE practice

TARGET="${1:-google.com}"
PORT="${2:-443}"

# Check status variables

DNS_OK=0
PING_OK=0
TCP_OK=0
HTTP_OK=0

echo "=================================="
echo "     NETWORK CONNECTIVITY CHECK"
echo "=================================="

echo ""
echo "Target: $TARGET"
echo "Port: $PORT"
echo ""

# DNS Resolution Check

check_dns() {

    echo "DNS RESOLUTION CHECK"

    local ipv4
    local ipv6

    ipv4=$(getent ahostsv4 "$TARGET" | awk 'NR==1 {print $1}')
    ipv6=$(getent ahostsv6 "$TARGET" | awk 'NR==1 {print $1}')

    if [[ -n "$ipv4" ]]; then
        echo "OK: IPv4 resolved to $ipv4"
    else
        echo "WARNING: No IPv4 address found"
    fi

    if [[ -n "$ipv6" ]]; then
        echo "OK: IPv6 resolved to $ipv6"
    else
        echo "WARNING: No IPv6 address found"
    fi

    if [[ -n "$ipv4" || -n "$ipv6" ]]; then
        DNS_OK=1
	return 0
    else
	DNS_OK=0
        return 1
    fi
}

# Ping Connectivity Check

check_ping() {

    echo ""
    echo "PING CONNECTIVITY CHECK"

    if ping -c 4 -W 3 "$TARGET" > /dev/null 2>&1; then
	PING_OK=1
	echo "OK: $TARGET is reachable via ICMP"
    else
	PING_OK=0
        echo "WARNING: No ICMP response from $TARGET"
    fi
}

# TCP Port Connectivity Check

check_port() {

    echo ""
    echo "TCP PORT CHECK"

    if nc -z -w 5 "$TARGET" "$PORT" 2>/dev/null; then
        TCP_OK=1
	echo "OK: TCP connection to $TARGET:$PORT succeeded"
    else
	TCP_OK=0
        echo "FAIL: Could not connect to $TARGET:$PORT"
        return 1
    fi
}

# HTTP/HTTPS Check

check_http() {

    echo ""
    echo "HTTP/HTTPS CHECK"

    local http_code

    if http_code=$(curl -L -sS -o /dev/null -w "%{http_code}" \
        --connect-timeout 5 \
        --max-time 15 \
        "https://$TARGET:$PORT"); then

        if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
            HTTP_OK=1
	    echo "OK: HTTPS request succeeded with HTTP $http_code"
        else
	    HTTP_OK=0
            echo "WARNING: HTTPS responded with HTTP $http_code"
        fi

    else
	HTTP_OK=0
        echo "FAIL: HTTPS request failed"
    fi
}

# Final Health Summary

print_summary() {

    echo ""
    echo "=================================="
    echo "       FINAL HEALTH SUMMARY"
    echo "=================================="

    if [[ "$DNS_OK" -eq 0 || "$TCP_OK" -eq 0 ]]; then
        overall_status="UNHEALTHY"
    elif [[ "$HTTP_OK" -eq 0 ]]; then
        overall_status="DEGRADED"
    else
        overall_status="HEALTHY"
    fi

    echo "Target: $TARGET"
    echo "Port: $PORT"
    echo ""

    if [[ "$DNS_OK" -eq 1 ]]; then
        echo "DNS: PASS"
    else
        echo "DNS: FAIL"
    fi

    if [[ "$PING_OK" -eq 1 ]]; then
        echo "ICMP: PASS"
    else
        echo "ICMP: NO RESPONSE"
    fi

    if [[ "$TCP_OK" -eq 1 ]]; then
        echo "TCP: PASS"
        if [[ "$HTTP_OK" -eq 1 ]]; then
            echo "HTTPS: PASS"
        else
            echo "HTTPS: FAIL"
        fi
    else
        echo "TCP: FAIL"
        echo "HTTPS: SKIPPED"
    fi

    echo ""
    echo "OVERALL STATUS: $overall_status"
    echo "=================================="

    case "$overall_status" in
    HEALTHY)
        exit 0
        ;;
    DEGRADED)
        exit 1
        ;;
    UNHEALTHY)
        exit 2
        ;;
esac
}

if check_dns; then

    check_ping

    if check_port; then
        check_http
    else
        echo ""
        echo "SKIP: HTTPS check because TCP connection failed."
    fi

else
    echo ""
    echo "SKIP: Remaining checks because DNS resolution failed."
fi

print_summary
