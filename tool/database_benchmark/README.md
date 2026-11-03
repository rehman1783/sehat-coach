# V1-M02 database comparison harness

ObjectBox sync parity: `dart run verify_objectbox_sync.dart` passes atomic record/outbox writes, injected exception rollback, stale revision rejection, another owner's preservation and reopen. Added dedicated synthetic SyncProfile/OutboxEntry entities; no production account data is involved. Additive schema evolution was rerun and passes after this model change. This remains single-process, sequential optimistic-concurrency coverage; cloud sync and multi-writer races are untested.

Sync transaction slice: `dart run verify_sync_atomicity.dart` passes for Drift. A synthetic profile revision update and matching outbox row commit in one transaction. An injected exception between them rolls back the revision; a stale expected revision is rejected; another owner is preserved; committed record/outbox values survive reopen. This is a local optimistic-concurrency primitive, not a functioning cloud sync engine. Concurrent writers, network retries, server acknowledgments, tombstones and ObjectBox parity remain unverified.

ObjectBox schema follow-up: `dart run verify_objectbox_migration.dart` passed on 21 October 2026. A preserved generated v1 binding creates the old store; the v2 binding adds nullable Food.source with existing UIDs retained. Existing values and the meal relation survive, and the new field survives a second reopen. Integrity and ObjectBox reactive checks also pass with v2. This is an additive model evolution test, not a destructive migration or failed-upgrade recovery test. Keep `lib/objectbox_v1.g.dart` as the frozen fixture; do not regenerate it. Earlier performance samples used the v1 model.

Reactive slice: `dart run verify_objectbox_reactivity.dart` passes a native query-stream check (initial food energy 100, changed to 250). `dart run verify_drift_reactivity.dart` passes a committed relational total update (+10) through Drift's table-update stream. The SQL adapter explicitly calls notifyUpdates; generated-table automatic invalidation remains untested. ObjectBox's check currently covers a single entity, not meal/food cross-entity dashboard dependencies. Both subscriptions are cancelled before closing stores. Package analysis passes.

Drift migration follow-up: `dart run verify_migration.dart` passed on 21 October 2026. Starting with the v1 fixture, it injects failure after ALTER TABLE, verifies column/version rollback, retries v2 successfully, checks all food rows and meal totals, and reopens v2 again. This covers a single additive SQL migration through Drift's migration callback. ObjectBox schema evolution, destructive migrations and crash recovery remain unverified.

Integrity follow-up: `dart run verify_integrity.dart` passed for both adapters on 21 October 2026. It updates existing food records and inserts a sentinel inside a transaction, deliberately throws, checks rollback, closes and reopens the store, and rechecks meal totals and search results. This verifies application-exception rollback and normal reopen, not power-loss recovery or migrations.

Latest: both candidates now run successfully. See [the comparison report](results-windows-2026-10-21.md) and its adjacent raw JSONL. The missing-DLL result below is historical setup evidence and has been resolved.

Status (21 October 2026): Drift and ObjectBox adapters implemented; ObjectBox model generated; isolated package analysis passes. Run `dart pub get`, `dart run build_runner build`, then `dart run run.dart` from this directory. ObjectBox also requires its Windows native runtime on the DLL search path.

First Windows x64 Dart JIT run: Drift completed five fresh-store repetitions and passed all correctness checks. Import samples in microseconds: 203580, 64076, 53919, 49696, 43532 (median 53919). Aggregation samples: 1579, 579, 528, 457, 875 (median 579). These include startup/warmup effects and are preliminary development evidence. ObjectBox could not run because objectbox.dll is absent (Windows error 126). This is a runtime setup failure, not a performance result. No winner or final database decision is established. Scratch databases were retained in the printed temporary directory for diagnosis.

The Drift adapter uses explicit SQL through Drift; generated production tables and migration tooling remain untested. The ObjectBox aggregation traverses ToOne relations in Dart, whereas SQLite aggregates with a SQL join. Report that execution difference when interpreting future results.

Use a separate temporary database for each adapter and each repetition. Run at least five fresh-store repetitions per candidate with identical fixtures, build mode, host and package lock. Preserve raw samples and report medians and p95, including fixture sizes and machine details. Close stores even on failures. Never use production health records.

Current workload: 10,000 synthetic food variants, 2,000 meal references, transactional import, six prefix queries repeated ten times after warmup, and relational energy aggregation. Synthetic values are not licensed food catalog data. Every returned result is checked before accepting timing output.

Remaining adapter acceptance: reactive dashboard emissions; recipe joins; rollback with an injected import error; forward migration with preserved records; failed migration recovery; outbox and conflict atomicity; persisted reopen; encryption/key integration; synonym/Urdu search; startup/memory/file size; Android profile-mode performance. These remain required before final selection.

Desktop timing cannot substitute for the Android benchmark currently deferred by the product owner. Keep database dependencies isolated from production until selection.
