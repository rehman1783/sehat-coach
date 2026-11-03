# Module roadmap

The sequence deliberately builds risk-bearing foundations before feature breadth. A later module may be designed early, but implementation cannot bypass its dependency gates.

| Module | Outcome | Depends on | Exit gate |
|---|---|---|---|
| **V1-M01 Governance and baseline** | Reproducible toolchain, approved V1 boundaries, design tokens, CI/test skeleton, decision ownership | None | Analyze/tests run; claims and external approvals are catalogued |
| **V1-M02 App and data foundation** | GetX controller/binding architecture, domain/use-case/repository boundaries, Drift-vs-ObjectBox benchmark, schema/migrations, secure storage abstractions | V1-M01 | Database decision recorded; migration/transaction/reactivity/import benchmarks pass |
| **V1-M03 Identity and account lifecycle** | 18+ eligibility, auth/session model, account isolation, sign-out/sync/export warnings, clear-local-data and delete-account separation | V1-M02 | Cross-account and unsynced-data tests pass; privacy flows approved |
| **V1-M04 Safe onboarding and profile** | Accessible onboarding, approved cities, measurement units, activity/goals, exclusions, reviewed metabolic estimate, clinician-plan override | V1-M03 | Calculation golden tests and safety/claims review pass |
| **V1-M05 Core offline tracker** | Pakistani food search, meals/recipes, portions, water, daily dashboard, history, offline edits | V1-M02–V1-M04 | Offline performance, relational queries, migrations, and usability gates pass |
| **V1-M06 Synchronization and admin publishing** | Outbox sync, conflict policy, tombstones, catalog/content/city/price publishing, audit trails | V1-M02, V1-M03, V1-M05 | Failure/retry/conflict and role/security tests pass |
| **V1-M07 AI coaching and assisted logging** | Blueprint generation, text/voice assistance, confidence/explanations, human approval and safe fallback | V1-M04–V1-M06 | Safety evals, cost limits, privacy review, and deterministic fallback pass |
| **V1-M08 Monetization and entitlements** | Subscription/credits/rewarded ads with server-authoritative ledger and restoration | V1-M03, V1-M06 | Store policy, replay/idempotency, entitlement, and refund tests pass |
| **V1-M09 Fasting and Bachat** | Fasting schedules/safety and verified grocery-price comparison/list planning | V1-M05, V1-M06 | Exclusion rules and price provenance/freshness gates pass |
| **V1-M10 Health-plan support and reports** | Doctor-provided plan capture, adherence/history, exportable reports, reminders | V1-M04–V1-M06 | No automatic override; consent/export/privacy review passes |
| **V1-M11 Launch hardening** | Performance, accessibility, observability, recovery, localization, store readiness, operational runbooks | All selected V1 modules | Release checklist and external acceptance complete |
| **V2-M01 Family/caregiver foundation** | Minors/teen safeguards, caregiver relationships, household controls | Post-V1 policy/legal design | Separate approved safety and consent model |

## Cross-cutting workstreams

Every module must consider security/privacy, offline behavior, accessibility, Urdu/Roman Urdu/local terminology, analytics minimization, migrations, observability, and admin/audit implications. These are acceptance dimensions, not end-of-project cleanup.

## Parallelism rule

UI components, content preparation, catalog research, and backend contracts may proceed in parallel only after V1-M01 establishes source-of-truth rules. Work that changes shared schema, authentication, sync, or clinical calculation contracts remains serialized through its owning module.

