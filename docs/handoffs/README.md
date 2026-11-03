# Implementation handoff protocol

One handoff covers one module or a deliberately small slice. It is not a request to “finish the app.”

## Handoff template

```text
Title and development ID (for example V1-M01 or V1-M04-S01)
Outcome
In scope
Out of scope
Authoritative requirements and decisions
Existing files/components to preserve
Allowed architecture and dependency constraints
Data model/migration requirements
Security, privacy, offline, and safety cases
UI references and required states
Acceptance criteria
Required tests and commands
Evidence to return
Known decisions that must not be reopened
Stop conditions / questions requiring owner input
```

## Implementer return template

```text
Summary
Changed files
Requirements addressed
Architecture/data changes
Migrations
Tests and exact results
Screenshots/device states
Security/privacy/safety checks
Deviations and assumptions
Known limitations
```

## Codex review output

Codex returns findings by severity with exact files/lines, fixes or a correction handoff, verification results, residual risks, updated traceability/status, and the next bounded handoff only after the active module is stable.

## First handoff

The first handoff should implement V1-M01 only: align the toolchain, establish CI/check commands, inventory and normalize design tokens, add architecture/test scaffolding without feature expansion, and produce a clean baseline evidence packet.

