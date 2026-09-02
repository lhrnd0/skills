---
name: check-port-availability
description: Check TCP port availability, local listener state, localhost connectivity, and public internet reachability. Use when the user asks whether ports are free, open, listening, forwarded, externally reachable, blocked by firewall/NAT, or available on their computer or public IP.
---

# Check Port Availability

## Overview

Use this workflow to distinguish these states:

- Available locally: no process is listening on the port.
- Open locally: a process is listening on the port.
- Accepting local connections: localhost TCP connection succeeds.
- Reachable from the internet: an external TCP checker can connect to the public IP and port.

Do not infer internet reachability from local checks alone.

## Inputs

Collect:

- Port numbers to check.
- Protocol if known; assume TCP unless the user says UDP.
- Whether the user wants local availability only, public reachability, or both.
- Optional expected process or app name.

Ask for missing port numbers unless they can be safely inferred from the active conversation.

## Local Checks

Check local TCP listeners:

```bash
lsof -nP -iTCP:<port> -sTCP:LISTEN
```

For multiple ports, repeat `-iTCP:<port>`:

```bash
lsof -nP -iTCP:<port1> -iTCP:<port2> -sTCP:LISTEN
```

Interpretation:

- Listener present: port is not available for another process; report process name and PID.
- No listener: port is locally available, but this does not prove firewall/router state.

Confirm socket state when useful:

```bash
netstat -anv -p tcp | rg '<port1>|<port2>'
```

Probe localhost connectivity:

```bash
nc -zv 127.0.0.1 <port>
```

If sandboxing blocks `nc` or `netstat` with `Operation not permitted`, rerun the same command with elevated permission and explain that it is a local socket inspection or local connection probe.

## Public Reachability

Get the public IP address from this machine:

```bash
curl -fsS https://api.ipify.org
curl -fsS https://ifconfig.me/ip
```

Prefer the public IPv4 address for typical home router port-forwarding checks. If the user specifically asks about IPv6, also test the IPv6 address.

Use an external checker that connects from outside the user's network:

```bash
curl -fsS https://tcpdata.com/port/<public-ip>/<port>
```

Interpret `status: "open"` as reachable from the internet. Interpret `closed` or `timeout` as not reachable externally, even if the local listener is present.

If `tcpdata.com` is unavailable, use another public TCP port checker API that connects from its own servers. Do not use only a local hairpin connection to decide public reachability.

## Reporting

Report:

- Ports checked and protocol.
- Local listener state, including process name and PID when present.
- Local connection probe result when run.
- Public address tested.
- External reachability result for each port.

If public checks fail while local checks pass, suggest likely causes in this order: router port forwarding, host firewall, VPN or carrier-grade NAT, ISP filtering, or service binding/configuration.
