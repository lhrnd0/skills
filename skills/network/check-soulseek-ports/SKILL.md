---
name: check-soulseek-ports
description: Verify SoulseekQt/Soulseek listening and obfuscated ports by applying the generic check-port-availability workflow with Soulseek-specific defaults and reporting. Use when the user asks whether Soulseek ports are open, available, forwarded, externally reachable, or when checking Soulseek listening/obfuscated ports such as 53648 and 53649.
---

# Check Soulseek Ports

## Overview

Use `$check-port-availability` for the actual local listener, localhost probe, public IP, and external reachability checks. This skill only supplies Soulseek-specific defaults and interpretation.

## Inputs

Use ports from the user's SoulseekQt settings screenshot or message. If none are supplied, ask for the listening port and obfuscated port. In the original setup that motivated this skill, SoulseekQt showed:

- Listening port: `53648`
- Obfuscated port: `53649`

Treat these as defaults only when the user clearly refers back to that setup.

## Delegated Workflow

Load and follow `$check-port-availability` with:

- Ports: Soulseek listening port and obfuscated port.
- Protocol: TCP.
- Expected process: `SoulseekQt`, `SoulseekQ`, or a clearly related Soulseek process.
- Scope: local listener check, local connection probe, and public reachability check unless the user asks for only one.

## Reporting

Report with Soulseek terminology:

- Listening port status.
- Obfuscated port status.
- Owning Soulseek process and PID when present.
- Public address tested.
- Whether each port is reachable from the internet.

If the ports are open locally but not reachable externally, suggest checking SoulseekQt settings, router port forwarding for both ports, macOS firewall, VPN or carrier-grade NAT, and ISP filtering.
