# Target architecture

## Architectural principles

1. **Wellness first:** the system tracks, explains, and helps users follow their own or clinician-provided plans; it does not prescribe treatment.
2. **Local-first operation:** normal logging reads/writes the local database immediately. Network synchronization is asynchronous.
3. **Server authority for scarce or trusted state:** entitlements, credits, purchases, admin approvals, catalog releases, AI quotas, and audit events are never client-authoritative.
4. **AI proposes; deterministic services calculate; users confirm:** AI extracts intent and matches candidates. Approved data and versioned calculations produce totals.
5. **Traceability:** every food value, price, AI result, report, and rule exposes provenance and version.
6. **Pakistan-first, configuration-led expansion:** avoid country-specific conditionals in domain entities when a market configuration can represent the difference.

## System context

```text
Flutter Android app
  ├─ encrypted local operational database
  ├─ offline food/catalog search index
  ├─ sync outbox + conflict resolver
  ├─ deterministic nutrition calculator
  └─ Firebase Auth client / Play Billing / rewarded ads
            │ authenticated HTTPS + App Check
            ▼
Trusted backend API
  ├─ authorization and account lifecycle
  ├─ sync ingestion/query APIs
  ├─ AI orchestration and redaction
  ├─ quotas, credit ledger, entitlements
  ├─ purchase verification + Play notifications
  ├─ catalog/feed/price publication
  ├─ report support and audit events
  └─ scheduled jobs
            │
   ┌────────┼───────────┬───────────────┐
   ▼        ▼           ▼               ▼
Firestore  Object      Gemini         Google Play
metadata/  storage     APIs           Billing
records    (optional)
   ▲
   │ privileged admin API
Secure web admin
```

The backend may be implemented with Firebase callable/HTTP functions or Cloud Run, but it must expose explicit versioned contracts and be testable independently. Direct client Firestore access is acceptable only for narrowly scoped user-owned data protected by tested security rules. Privileged mutations go through the backend.

## Mobile application boundaries

Use feature-first modules with domain/application/data/presentation boundaries:

```text
lib/
  app/                 routing, bootstrap, dependency wiring
  core/                errors, IDs, clock, connectivity, crypto, sync primitives
  features/
    auth/
    onboarding/
    profile/
    catalog/
    meals/
    hydration/
    progress/
    feed/
    ai_logging/
    fasting/
    bachat/
    plans/
    reports/
    entitlements/
    settings/
```

GetX is the product-owner-selected state-management standard. Feature bindings create controllers with explicit lifecycle ownership; controllers depend on application use cases and repository interfaces. Presentation code must not call Drift, ObjectBox, Firebase, or HTTP clients directly. Avoid app-wide mutable service locators for user-owned data; reset account-scoped controllers and dependencies on sign-out. Keep navigation and state management independently testable.

## Local storage model

Drift/SQLite is the preferred local database candidate, subject to a short, reproducible benchmark against ObjectBox. The benchmark must use representative Pakistani catalog volume and relational meal/recipe data and measure:

- offline name/synonym/prefix food search;
- relational meal, recipe, serving, and source queries;
- reactive dashboard aggregation;
- forward migrations and failed-migration recovery;
- transactional bulk catalog imports;
- outbox/conflict-resolution transactions;
- platform-backed encryption integration;
- Android startup/query/import performance and maintenance complexity.

Record fixtures, device/emulator profile, commands, results, tradeoffs, and the final decision. Both candidates must sit behind repository interfaces so domain/application logic remains storage-independent. Hive is not a candidate for the operational relational store.

Each user-owned record includes:

```text
id                 client-generated UUID
ownerId            immutable Firebase UID
schemaVersion      local/entity schema
revision           monotonic server revision where applicable
createdAtClient    device time, informational
updatedAtClient    device time, informational
updatedAtServer    trusted ordering timestamp after sync
deletedAt          tombstone, nullable
syncState          clean | pending | failed | conflicted
idempotencyKey     operation identity where required
```

Local stores must be physically or cryptographically partitioned by UID. Successful sign-out closes the active store and removes authentication tokens, decrypted/in-memory state, account-specific caches, encryption keys, and sensitive account data from the device. Synchronized history remains in the cloud and is restored only after the same UID authenticates again.

Before sign-out, inspect the durable outbox. If pending changes exist, show their count and consequences and offer synchronization first when online. Never silently destroy pending health records. If offline, use an explicitly initiated encrypted export/recovery package only if its key custody, integrity, import, expiry, and user comprehension can be made safe; otherwise keep sign-out incomplete and offer Cancel or an explicitly acknowledged destructive discard. Sign Out, Clear Local Data, and Delete Account are separate use cases and UI actions. Account switching must prove that no previous UID data is queryable or rendered.

## Synchronization model

Firestore offline persistence alone resolves competing document changes with last-write-wins. That is insufficient for ledgers, concurrent edits, and auditable health history, so use an explicit outbox protocol:

1. A user action commits the domain mutation and outbox event in one local transaction.
2. The UI reads the new local state immediately.
3. A sync worker submits ordered, idempotent operations when online.
4. The server authenticates owner, validates schema/business rules, deduplicates the idempotency key, and assigns a server revision/time.
5. The client applies acknowledgements and pulls server changes since its cursor.
6. Tombstones are retained until every required replica/retention window is satisfied.

Conflict policies:

| Entity | Policy |
|---|---|
| Meal/hydration/weight log | Immutable event plus explicit correction/version; avoid destructive overwrite |
| Profile preference | Field-level last accepted edit with visible conflict only when material |
| User custom recipe | Fork/merge or user-selected version when both changed |
| Approved catalog/price/feed | Server-published immutable version; client replaces cache atomically |
| Medical/wellness plan | Preserve original; suggestions create proposed revisions requiring approval |
| Likes/dislikes | Server upsert keyed by user+post |
| Credits/purchases/entitlements | Server-only ledger/state machine; never merge client balances |

## Core cloud collections/services

Logical model (physical collection layout must be threat-modelled and indexed):

- `users`, `userProfiles`, `userConsents`, `accountDeletionJobs`
- `mealEvents`, `hydrationEvents`, `weightEvents`, `goalRevisions`
- `customFoods`, `customRecipes`
- `catalogReleases`, `foods`, `recipes`, `servingDefinitions`, `nutritionSources`
- `marketPriceReleases`, `marketPrices`, `markets`, `cities`
- `feedPosts`, `feedReactions`, `contentSources`
- `aiRequests`, `aiUsageLedger`, `promptVersions`, `modelPolicies`
- `plans`, `planRevisions`, `planApprovals`, `adherenceEvents`
- `products`, `entitlements`, `purchaseEvents`, `creditLedger`
- `staff`, `roles`, `adminAuditEvents`, `reviewQueues`

Avoid one ever-growing document per user. Logs are individual events, partitioned/queryable by owner and time. Catalog releases are immutable snapshots so old meal calculations remain explainable.

## Nutrition and food catalog

The approved food layer is not AI-generated at read time. It contains:

- canonical food/recipe ID and localized names/synonyms;
- preparation and region;
- nutrients per normalized reference amount;
- household measures with conversion range/confidence;
- whether oil/sauce is already included;
- source/license/citation and source record ID;
- reviewer status and review history;
- version and effective dates.

Meal calculation stores both the accepted inputs and a calculation snapshot. Later catalog corrections do not silently rewrite historical logs; the user may opt to recalculate with a newer catalog version.

The initial oil model is an explicit heuristic. It returns a range and explanation and only applies to compatible oil-excluded records. Calibration data, error metrics, and reviewer approval are prerequisites for accuracy marketing.

## Adult eligibility and metabolic estimates

V1 accepts adults aged 18+. The eligibility check stores only the necessary declared date/age information according to the final privacy design; routine identity-document collection is prohibited. An ineligible user cannot complete account setup. Age policy is configuration/versioned so a future safeguarded minor pathway can be introduced without weakening the adult pathway.

For eligible adults, Mifflin–St Jeor may estimate resting energy expenditure using its required physiology input, age, height, and weight. A documented activity factor produces an estimated expenditure range. Goal type, applicable target weight, and preferred pace inform a proposal—not a guaranteed outcome or date.

The calculation service returns inputs, equation/version, assumptions, estimated range, exclusions, and warnings. Pregnancy, breastfeeding, special medical circumstances, and clinician-provided plans bypass routine weight-loss automation. Clinician-provided instructions remain authoritative and immutable. Calorie floors, pace limits, warning language, and clinically consequential actions remain disabled until professional review approves them. Users may review and adjust goals only inside those approved constraints.

## Market and city configuration

The V1 seed configuration contains Karachi, Lahore, Islamabad, Rawalpindi, Faisalabad, Multan, Peshawar, Quetta, Hyderabad, and Gujranwala plus `other`. City is optional for core food logging and is never an authorization boundary. Admin-published market configuration can add, rename, activate, or retire cities without an application release while preserving stable IDs in historical records.

Price availability is independent per city/market/release. A city selection never implies price coverage. The client displays current pricing only from an active, non-expired approved release and always shows source, normalized unit, city/market, and last-updated time. Missing or stale data produces an unavailable/stale state, never a fabricated fallback.

## AI orchestration

The app sends authenticated, consented requests to the backend. The backend:

1. enforces entitlement/credit reservation and rate limits;
2. minimizes/redacts payload data;
3. selects a versioned prompt/model/schema;
4. calls the provider;
5. validates strict structured output;
6. matches candidate IDs against the approved catalog;
7. returns candidates, assumptions, ranges, and confidence;
8. finalizes usage only according to the defined failure/refund policy.

The mobile user reviews candidates. Only after confirmation does deterministic application code create the meal event. Raw audio/images should have the shortest viable retention, with a default of deletion after successful processing unless the user expressly chooses otherwise. The architecture must support provider replacement and test fixtures without live AI calls.

## Health plans and safety model

Represent plan content by provenance:

- `user_defined`
- `clinician_provided` (claimed provenance; verification state separate)
- `general_guidance`
- `ai_suggested`
- `clinician_approved`

Never mutate the original instruction. A change creates a proposed revision containing differences, rationale, author type, timestamps, and approval state. Clinically significant restrictions stay unapplied until the required approval policy is satisfied.

Warnings use conservative informational language and show the underlying inputs. Emergency or symptom advice must use approved static content, not generative responses.

## Authentication and authorization

- Firebase Auth: email/password with verification and Google Sign-In for Android V1.
- Require recent authentication for account deletion and sensitive credential changes.
- Link providers carefully to avoid duplicate accounts.
- Firebase UID is identity, not authorization.
- Firestore/Storage rules restrict user paths by UID and immutable ownership fields.
- Backend verifies Firebase ID tokens and App Check, then applies domain authorization.
- Admin users are held in a separate staff authorization model with MFA policy, roles, revocation, and audit history.

## Monetization and credits

Google Play is the source of purchase events; the backend is the source of app entitlements. Subscription and consumable verification, acknowledgement/consumption, and real-time developer notifications are handled server-side.

Credit balance is derived from an append-only ledger. Entries include grant/spend/refund/expiry/adjustment types, product/ad/AI request references, idempotency key, actor, and server timestamp. AI calls reserve credit before provider execution and settle or release it deterministically.

Rewarded ads grant benefits only after validated completion callbacks under a configured reward definition. Health conditions must not determine ad targeting, and ads must not interrupt critical health/safety interactions.

## Admin architecture

The separate web admin uses the same trusted backend, never broad direct database credentials. Initial roles:

- `platform_owner`: staff roles and all domains;
- `catalog_editor` / `catalog_reviewer`;
- `content_editor` / `content_reviewer`;
- `market_editor` / `market_reviewer`;
- `billing_support` (no health-content access by default);
- `auditor` (read-only audit metadata).

Use four-eyes approval for public nutrition rules, health facts, and clinically sensitive content. Every publish/revoke/price/catalog/staff action records before/after metadata and actor.

## Privacy and security

Before production, complete data-flow mapping and a threat model covering account takeover, cross-user cache leakage, insecure Firestore rules, replayed sync writes, purchase fraud, credit races, prompt injection, malicious catalog imports, admin compromise, and report leakage.

Minimum controls:

- TLS; platform-backed secret/key storage; encrypted local health database;
- secret manager for backend credentials;
- App Check/Play Integrity after monitored rollout;
- strict input/output schemas and upload limits;
- malware/type validation for imports and media;
- least-privilege service accounts;
- privacy-safe structured logs and alerting;
- deletion/export workflows with measurable completion;
- dev/staging/production separation and synthetic non-production data.

## Observability and quality

Track without logging raw meal/health text:

- onboarding completion and time distributions;
- manual search success/no-result/correction rates;
- AI match acceptance/edit/rejection rates by catalog item and prompt version;
- estimate range and calibrated error metrics;
- sync queue age, failures, conflicts, and duplicates;
- crash-free sessions, startup time, query latency, and low-end device performance;
- AI/provider cost and latency distributions;
- purchase/entitlement reconciliation discrepancies;
- content/catalog publication and rollback events.

Billing client telemetry is restricted to fixed payload-free categories and is injected at the authenticated account composition boundary. Raw purchase tokens, owner identifiers, product/price data, exceptions and backend bodies are not accepted by that client event contract. Emission is best-effort and non-blocking; telemetry failure cannot alter or interrupt a billing flow.

Every phase requires automated tests plus a small owner acceptance checklist. Production claims require measured evidence, not just passing code tests.
