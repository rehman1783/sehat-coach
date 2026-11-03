# ADR-001 — Select Drift/SQLite for local persistence

Date: 21 October 2026  
Status: Accepted for implementation; Android and security release gates remain open  
Module: V1-M02

## Decision

Use Drift with SQLite, rather than ObjectBox, as Sehat Coach's production local persistence stack. Keep domain and application code behind repository interfaces. Use a per-account encrypted database and an explicit transactional outbox. Do not add an ObjectBox production adapter unless later evidence invalidates this decision.

This selection unblocks implementation; it does not declare production persistence complete or security-approved.

## Evidence considered

- Identical Windows synthetic workload: 10,000 foods and 2,000 meal references across five fresh stores per candidate.
- Drift median import was 53.292 ms versus ObjectBox 196.765 ms.
- ObjectBox median prefix search was 0.864 ms versus Drift 1.352 ms; both were fast in this synthetic desktop workload.
- Drift relational aggregation median was 0.528 ms versus ObjectBox 23.543 ms. The implementations differed—SQL join/SUM versus Dart relation traversal—so this supports our planned query style rather than a universal database claim.
- Both candidates passed the bounded rollback/reopen, additive evolution, reactive update, owner isolation, revision and local record/outbox checks.
- Drift passed an isolated SQLite3MultipleCiphers proof with correct-key reopen, wrong/missing-key rejection, additive migration and rollback.
- Suitable ObjectBox database-encryption integration was not established in the inspected Dart API. Application-level field encryption would weaken ordinary search/query behavior and increase custom security work.

## Rationale

Sehat Coach needs relational meals/recipes, auditable migrations, multi-record transactions, reactive dashboard queries, bulk catalog imports and an atomic outbox. Drift provides the clearest fit for those requirements, conventional SQLite inspection and migration behavior, and the only verified encrypted-database path from this comparison. ObjectBox's faster prefix search does not outweigh the transaction, relational-query, encryption and maintenance advantages for this product.

## Required implementation constraints

- Use Drift generated tables and migrations rather than scattering raw SQL through features.
- Keep every owner-scoped repository behind an interface; presentation and GetX controllers must never access Drift directly.
- Partition database files and keys by authenticated UID. Never open an account store before resolving its UID and protected key.
- Use SQLite3MultipleCiphers only after runtime cipher detection; never fall back to plaintext.
- Commit each local mutation and outbox operation in one transaction. Apply a pulled page and its cursor in one transaction.
- Preserve tombstones and conflicting versions according to the entity-specific policy.
- Do not store health profiles in preferences or an unencrypted fallback database.

## Open verification gates

- Android 10+ build and profile-mode benchmark, including encrypted startup, search, bulk import, dashboard queries and file size.
- Android Keystore-backed key wrapping, backup/restore behavior and account-switch isolation.
- Interrupted migration and recovery against the encrypted production schema.
- Durable sign-out, Clear Local Data and Delete Account integration with pending-record protection.
- Security review of key lifecycle and database configuration.

The owner's device/emulator-testing deferral remains in effect. These are release and integration gates, not a reason to keep both database implementations in production.
