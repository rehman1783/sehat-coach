# Sehat Coach product strategy index

Status: Baseline v1.1 (Development Decisions Round 2 applied), 18 October 2026

These documents translate the product master specification and the subsequent strategic decisions into an implementation control set. They preserve the complete approved vision while separating committed requirements, phased delivery, validation gates, and unresolved decisions.

The repository-wide delivery index is [../../INDEX.md](../../INDEX.md). That index controls module sequencing, implementation handoffs, review status, and acceptance evidence; this directory remains the detailed requirements and architecture source set.

- [Requirements traceability matrix](01-requirements-traceability.md)
- [Target architecture](02-target-architecture.md)
- [Phased implementation backlog](03-phased-backlog.md)
- [Open product decisions](04-open-decisions.md)

## Source precedence

1. Explicit later owner decisions override conflicting assumptions in the master specification.
2. The original master specification remains the vision inventory; a feature may be phased but must not be silently deleted.
3. Unvalidated clinical, nutrition, price, and regulatory claims remain gated until suitable evidence and approval exist.
4. Code and completion reports do not prove acceptance. Each backlog gate requires its stated verification evidence.

## Approved V1 planning defaults

- Adults aged 18+ only; no identity-document collection for routine age eligibility.
- GetX is the Flutter state-management standard, selected by the product owner on 20 October 2026.
- Drift/SQLite is selected for implementation by ADR-001 after the bounded ObjectBox comparison; Android and security verification remain open gates.
- Successful sign-out removes account-specific sensitive local data after protecting unsynchronized records.
- Mifflin–St Jeor plus an activity estimate may provide an adult starting estimate, subject to safety review and exclusions.
- Initial cities are Karachi, Lahore, Islamabad, Rawalpindi, Faisalabad, Multan, Peshawar, Quetta, Hyderabad, and Gujranwala, plus configurable Other city support.

## Current repository baseline

The repository contains a Flutter UI prototype with splash, onboarding, a preliminary dashboard, theme primitives, and limited widget testing. Firebase, durable local persistence, synchronization, food data, AI, admin tooling, billing, notifications, PDFs, and production observability are not yet integrated. `android/gradle.properties` had a pre-existing local modification when this baseline was written and must not be overwritten without review.
