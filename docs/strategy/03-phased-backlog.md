# Phased implementation backlog

Only one phase/increment should be active at a time. A phase is not accepted because its screens exist; its gate must pass with recorded evidence. Features in later phases remain approved scope.

## P0 — Product, safety, and engineering baseline

**Goal:** establish boundaries that prevent expensive rework.

- P0.1 Create product terminology and claims guide: wellness versus medical language.
- P0.2 Complete data inventory, retention/deletion proposal, consent map, and initial threat model.
- P0.3 Select environments, package IDs, Firebase projects, secret handling, CI, and release branching.
- P0.4 Establish GetX controller and binding conventions and benchmark preferred Drift/SQLite against ObjectBox using representative food search, relational records, reactive dashboards, migrations, bulk imports, sync/conflicts, encryption integration, Android performance, and maintainability.
- P0.5 Define API/error/versioning/idempotency conventions and test strategy.
- P0.6 Convert the current theme/onboarding prototype into a navigable, accessibility-tested shell without adding fake production data behavior.

**G0.1:** owner accepts claims, privacy boundaries, data categories, and medical safety boundary.  
**G0.2:** clean CI runs analyze/unit/widget checks; development/staging configuration cannot address production accidentally.

## P1 — Identity, profile, onboarding, and sync foundation

**Goal:** a registered user can complete a defensible onboarding and safely use account-scoped local data.

- P1.1 Firebase bootstrap, verified email/password, Google Sign-In, provider linking, auth error UX.
- P1.2 Account-scoped encrypted local database, migrations, secure key lifecycle, and repository abstractions independent of the selected database.
- P1.2a Implement separate Sign Out, Clear Local Data, and Delete Account flows. Sign-out clears account-local sensitive state only after pending-record detection, online sync offer, and explicit recovery/discard handling; same-account reauthentication restores cloud history.
- P1.3 Refactor onboarding state into domain models and durable drafts.
- P1.4 Enforce the 18+ V1 eligibility boundary without identity-document collection and keep age-policy configuration extensible for a future safeguarded minor pathway.
- P1.5 Add Mifflin–St Jeor adult estimation, activity level, applicable target/pace inputs, estimate ranges, exclusions, unrealistic-goal flags, and review UI. Leave unreviewed safety floors/clinically consequential recommendations inactive.
- P1.6 Seed configurable Pakistan/PKR market data for Karachi, Lahore, Islamabad, Rawalpindi, Faisalabad, Multan, Peshawar, Quetta, Hyderabad, Gujranwala, and Other city; core features remain city-independent.
- P1.7 Implement outbox/pull cursors, idempotency, tombstones, retry/backoff, and conflict test harness.
- P1.8 User profile cloud sync and privacy-safe diagnostics.

**G1.1:** authentication abuse/error flows, verification, provider linking, 18+ eligibility, account isolation, and security rules pass emulator/integration tests.  
**G1.2:** eligible-adult targets are reproducible from stored inputs and equation version; exclusions do not receive generic weight-loss calculations; no exact measurement or milestone is promised; onboarding works at supported text scales and practical device sizes.  
**G1.3:** airplane-mode create/edit/delete, restart, reconnect, duplicate upload, concurrent edit, pending-record sign-out, offline sign-out, same-account restore, destructive discard confirmation, and account-switch tests pass without silent loss or leakage.

## P2 — Pakistani catalog and core tracker

**Goal:** prove useful transparent manual Pakistani food tracking without AI.

- P2.1 Establish legally usable initial nutrition sources and review workflow.
- P2.2 Define foods, recipes, localized synonyms, household measures, oil-inclusion state, sources, review status, and immutable releases.
- P2.3 Import a deliberately bounded launch catalog covering prioritized common meals; define coverage metric.
- P2.4 Build indexed offline search with spelling/synonym support and no-result notes.
- P2.5 Build meal composer, portion editor, recipe/oil explanation, deterministic calculator, correction history, and daily timeline.
- P2.6 Add hydration and weight/progress event logging.
- P2.7 Build dashboard from real local data, including empty/loading/offline/sync-error states.
- P2.8 Add custom foods/recipes and prevent them from entering the approved catalog implicitly.

**G2.1:** curated golden tests reproduce catalog values/calculations; oil is not double-counted; offline search/log/edit/restart/sync passes; users can see source, assumptions, and estimate status. A nutrition reviewer is not implied unless actually engaged.

## P3 — Secure admin, catalog publishing, market prices, and content feed

**Goal:** operate changing content safely without app releases.

- P3.1 Create separate web admin authentication, MFA policy, RBAC, revocation, and audit events.
- P3.2 Build catalog and serving-source edit/review/publish/rollback workflows.
- P3.3 Build city configuration plus market/unit/source-aware price import, review, publication, expiry, and stale marking. Adding a city must not require a mobile release.
- P3.4 Build scheduled quote/health-fact authoring, source review, locale/category, publication, expiry, and rollback.
- P3.5 Add mobile authenticated feed with combined timeline, tabs, offline cache, and private reaction upsert.
- P3.6 Add atomic signed/versioned mobile catalog and price snapshot download.

**G3.1:** privilege matrix and negative authorization tests pass; every privileged change is auditable; malformed imports cannot partially publish; previous release rollback works.  
**G3.2:** scheduling/timezone, empty days, multi-post days, tabs, private reactions, offline cache, and identity non-disclosure pass integration/E2E tests.

## P4 — Welcome blueprint and AI-assisted logging

**Goal:** add paid-quality AI convenience without making AI the nutrition authority.

- P4.1 Backend AI gateway, consent, minimization, schemas, prompt/model registry, quotas, rate limits, observability, and provider abstraction.
- P4.2 One-time welcome blueprint with versioned inputs/output and safe non-medical claims.
- P4.3 Roman Urdu/English text extraction into catalog candidates, confidence, ranges, assumptions, and review UI.
- P4.4 Voice capture/transcription, permission UX, cancellation, upload retry, and raw-media retention controls.
- P4.5 Create representative, de-identified Pakistani language evaluation sets and regression scoring.
- P4.6 Add graceful manual fallback for provider failure, low confidence, unsupported food, and quota exhaustion.

**G4.1:** no provider secret in clients; hostile/invalid output is rejected; the same accepted catalog inputs yield deterministic totals; low-confidence results require review; cost/latency/acceptance metrics are recorded.  
**G4.2:** voice permission denial, interruption, offline state, retries, cancellation, deletion, mixed language, and accessibility flows pass.

## P5 — Subscriptions, credits, and rewarded access

**Goal:** monetize AI safely with reconcilable entitlements.

- P5.1 Define configurable products, feature gates, allowance periods, credit costs, expiry/refund policy, and failure charging policy.
- P5.2 Integrate Play Billing subscriptions and consumable credit top-ups.
- P5.3 Verify purchases server-side; process acknowledgement/consumption and real-time lifecycle notifications.
- P5.4 Implement append-only credit ledger, reservations, settlement/refund, reconciliation, and support tooling.
- P5.5 Integrate explicitly selected rewarded ads and validated reward grants.
- P5.6 Build paywall, allowance/credit history, restore/reconcile, offline entitlement grace, and transparent error UX.

**G5.1:** replayed receipts, duplicate notifications, concurrent spends, refund/revoke, expiration, offline attempts, account switching, and provider outage cannot mint/spend incorrectly.  
**G5.2:** rewards require confirmed completion, are idempotent, never target sensitive health traits, and do not block safety information.

## P6 — Fasting and Bachat

**Goal:** deliver differentiated cultural routines and affordable planning on trusted data.

- P6.1 City-based prayer calculations, configurable method/manual offset, Ramadan/Sunnah schedules, and optional precise location.
- P6.2 Notification scheduler for Suhoor/Iftar and reminder suppression with timezone/DST/device-restart handling.
- P6.3 Night hydration schedule as configurable wellness guidance with contraindication messaging.
- P6.4 Deterministic free Bachat planner using approved price snapshots.
- P6.5 Add diet/allergy/preference, calorie/protein, variety, serving, availability, pack/waste, and budget constraints.
- P6.6 Add transparent swap comparison and later entitled AI personalization.

**G6.1:** prayer/fasting results pass reference fixtures for supported cities/methods and device/timezone changes; safety copy is approved.  
**G6.2:** optimizer satisfies every declared constraint, explains infeasibility, exposes price freshness/source, and never labels missing/stale data as live.

## P7 — Plans, condition-aware support, and shareable reports

**Goal:** help users follow existing plans without crossing into unsupervised treatment.

- P7.1 Plan import/manual entry with provenance and immutable original.
- P7.2 Proposed plan revisions, diff, rationale, explicit approval, and clinician-review state.
- P7.3 Adherence tracking, meal swaps, and entitled regeneration.
- P7.4 Configurable carbohydrate/sodium/hydration goals with provenance and conservative wording.
- P7.5 7/14/30-day PDF summary with estimated/missing/user-entered distinctions, provenance, and local sharing.
- P7.6 Professional review workflow for health rules, fasting content, and report language.

**G7.1:** AI cannot silently apply a medical-plan change; original instructions remain recoverable; clinically significant suggestions honor the approval policy; unreviewed rules are not presented as validated.  
**G7.2:** PDF fixtures are numerically traceable to records, visually verified, accessible where feasible, privacy-reviewed, and clearly labeled as a wellness summary unless later approval supports another claim.

## P8 — Photo AI, settings completion, and launch hardening

**Goal:** complete preserved V1 features and decide the public-release bundle using evidence.

- P8.1 Photo plate candidate analysis with media consent/retention, confidence, and mandatory review.
- P8.2 Complete export, cache management, account deletion, notification controls, location, goals, coach tone, and accessibility settings.
- P8.3 Performance/battery/network testing on representative low- and mid-range Pakistani Android devices.
- P8.4 Security assessment, privacy/legal review, store data-safety declarations, support/runbooks, backup/restore, incident and rollback drills.
- P8.5 Run closed beta measuring search coverage, correction rate, onboarding completion, retention, AI acceptance, sync reliability, and costs.
- P8.6 Hold an explicit release-scope review. Features may be withheld from the first public build for safety/readiness, but remain traceable and scheduled.

**G8.1:** launch candidate meets agreed reliability/security/privacy/accessibility thresholds and every excluded approved feature has an owner-approved disposition—not silent deletion.

## V2 — Family and caregiver terminal

- V2.1 Household/dependent identity, consent, guardianship, invitations, granular grants, and revocation.
- V2.2 Subject-aware voice attribution with mandatory confirmation.
- V2.3 Remote caregiver sync and profile-specific reports.
- V2.4 Prescription/medication reminders constrained to recorded clinician instructions.
- V2.5 Family subscriptions and member lifecycle.

V2 begins only after a separate privacy, safeguarding, and authorization design is accepted.
