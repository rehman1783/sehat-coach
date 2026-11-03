# Requirements traceability matrix

Status values: **Prototype** means UI or scaffolding exists but is not production-complete; **Planned** means approved and backlog-mapped; **Gated** means approved in principle but blocked by a decision, evidence, professional review, or release gate; **V2** is preserved outside V1.

Verification IDs refer to the phased backlog.

## Product, market, and safety

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| PRD-001 | Position Sehat Coach as a general wellness, nutrition, and healthy-lifestyle tracker. | Decision 1 | P0 | Planned | G0.1 |
| PRD-002 | Never prescribe treatment, change medication, or independently impose patient-specific medical restrictions. | Decision 1 | P0/P7 | Planned | G0.1, G7.1 |
| PRD-003 | Preserve clinician/user-provided plans and distinguish them from AI suggestions. | Decision 1 | P7 | Immutable original, capture/authorship provenance, encrypted persistence/UI and separate auditable revisions implemented | G7.1 |
| PRD-004 | Require explicit user approval before applying medical-plan AI suggestions. | Decision 1 | P7 | Approval gate and proposal-linked revision persistence implemented; clinically significant changes also require professional-review evidence | G7.1 |
| PRD-005 | Make Pakistan and Android the first launch market/platform. | Decisions 2/8 | All V1 | Planned | Release gate |
| PRD-006 | Design country, currency, language, food-source, and market configuration for later expansion. | Decision 2 | P1 | Planned | G1.2 |
| PRD-007 | Treat transparent Pakistani meal estimation as the core product proof. | Decision 3 | P2 | Planned | G2.1 |
| PRD-008 | Do not present estimates as laboratory-accurate or clinically validated when they are not. | Decisions 3/4 | P0/P2 | Planned | G0.1, G2.1 |
| PRD-009 | Preserve iOS as a later platform and add Apple Sign-In with that release. | Decision 2/7 | Post-V1 | Gated | Decision D-022 |

## Identity, onboarding, and profile

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| ID-001 | Require an authenticated account; no anonymous launch mode. | Decision 7 | P1 | Domain/runtime gate and account-access UI implemented; production auth adapter and removal of preview bypass pending | G1.1 |
| ID-002 | Support verified email/password and Google Sign-In on Android. | Decision 7 | P1 | Password/Google/verification/recovery contracts and UI implemented; provider SDK, token validation and deep links pending | G1.1 |
| ID-003 | Prevent cross-account local and cloud data leakage on sign-out, account switch, and device reuse. | Decision 7 | P1 | Domain, encrypted-runtime isolation and safe switch/sign-out presentation implemented; production provider/cloud/device verification pending | G1.1/G1.3 |
| ID-004 | Provide quick onboarding and defer optional detail to advanced setup. | Decision 8 | P1 | Prototype | G1.2 |
| ID-005 | Capture goal, age, biological parameters required by the selected metabolic equation, height, weight, unit system, location, kitchen routine, overlays, and coaching tone. | Master §5 | P1 | Prototype | G1.2 |
| ID-006 | Add activity level, target weight, goal pace, and safety constraints before producing a real target or milestone. | Derived prerequisite | P1 | Planned | G1.2 |
| ID-007 | Generate one personalized welcome blueprint per account after onboarding. | Other confirmed requirements | P4 | Planned | G4.1 |
| ID-008 | Keep blueprint inputs, model/prompt version, output, timestamp, and user confirmation auditable. | Safety prerequisite | P4 | Planned | G4.1 |
| ID-009 | Permit manual country/city override; do not require GPS for onboarding. | Master §4/5 | P1 | Trusted onboarding defaults to manual selection with no GPS permission or pre-consent IP lookup; preview-only detection remains separate | G1.2 |
| ID-010 | Support English and Pakistani Roman Urdu presentation; full Urdu-script localization remains a separate release decision. | Master §11 | P1+ | Prototype | D-012 |
| ID-011 | Restrict V1 account setup to users aged 18+ and provide a respectful ineligible-age exit without collecting identity documents. | Round 2 Decision 1 | P1 | Implemented in registration contract and account-access UI; server enforcement/provider integration pending | G1.1/G1.2 |
| ID-012 | Keep age-policy data/configuration extensible so safeguarded support for ages 16–17 can be added later without applying adult formulas. | Round 2 Decision 1 | P1 | Planned | G1.2 |
| ID-013 | Use Mifflin–St Jeor only as an eligible-adult resting-energy estimate and apply a documented activity estimate. | Round 2 Decision 4 | P1 | Planned | G1.2 |
| ID-014 | Collect target weight/pace only when applicable; describe targets as estimates and never promise a target date. | Round 2 Decision 4 | P1 | Planned | G1.2 |
| ID-015 | Flag unrealistic goals/rates and permit review/adjustment only within professionally reviewed constraints. | Round 2 Decision 4 | P1 | Gated | D-029 |
| ID-016 | Exclude pregnancy, breastfeeding, special medical circumstances, and clinician-provided plans from routine automatic weight-loss calculations. | Round 2 Decision 4 | P1/P7 | Onboarding exclusion and active entered-plan precedence policies implemented; qualified review/device acceptance pending | G1.2/G7.1 |
| ID-017 | Support the ten approved launch cities plus an admin-configurable Other city option; core logging must remain city-independent. | Round 2 Decision 5 | P1/P3 | In implementation: bundled ten-city/Other fallback plus verified versioned runtime city releases complete; server publishing/cache and admin UI pending; core logging remains independent | G1.2/G3.1 |

## Offline data and synchronization

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| SYNC-001 | Manual food, meal, hydration, weight/progress, and supported routine operations work after prior authentication while offline. | Decision 7 | P1/P2 | In implementation: food, meals, hydration, weight, fasting preferences and original health plans/approvals have local owner-scoped persistence/outbox; live transport/device acceptance pending | G1.3/G2.1 |
| SYNC-002 | Store user health data in an encrypted local database partitioned by account ID. | Master §10 + safety | P1 | Planned | G1.3 |
| SYNC-003 | Synchronize automatically when connectivity returns. | Decision 7 | P1 | In implementation: transport-neutral reconnect/resume/manual trigger orchestration and duplicate coalescing verified; platform connectivity and live transport pending | G1.3 |
| SYNC-004 | Give every mutable record a client-generated UUID, owner ID, schema version, revision, created/updated timestamps, and deletion tombstone. | Architecture prerequisite | P1 | Planned | G1.3 |
| SYNC-005 | Make uploads idempotent and retry-safe; duplicate requests cannot duplicate logs, charges, or credits. | Decision 7 | P1/P5 | Planned | G1.3/G5.1 |
| SYNC-006 | Define field/entity-specific conflict behavior; do not rely on unqualified last-write-wins. | Decision 7 | P1 | Planned | G1.3 |
| SYNC-007 | Keep purchases, entitlements, credits, admin approvals, and AI usage server-authoritative. | Confirmed security requirement | P3/P5 | Planned | G3.1/G5.1 |
| SYNC-008 | Support forward migrations, interrupted migration recovery, and backward-compatible server contracts. | Architecture prerequisite | P1 | Planned | G1.3 |
| SYNC-009 | On successful sign-out, clear tokens, in-memory state, account caches, encryption keys, and account-specific local data. | Round 2 Decision 3 | P1 | Domain, secure runtime adapter and account-safety presentation implemented; live auth/device verification pending | G1.3 |
| SYNC-010 | Detect unsynchronized records before sign-out, offer sync when online, and never silently destroy unsynchronized health records. | Round 2 Decision 3 | P1 | In implementation: durable detection/sign-out guard plus owner-scoped dashboard pending/failure visibility complete; live online sync offer pending authenticated transport | G1.3 |
| SYNC-011 | When offline sign-out is requested with pending records, support an explicit protected recovery path if feasible or block destructive completion with clear choices. | Round 2 Decision 3 | P1 | Implemented as explicit offline block and online sync-first presentation; portable export decision remains open | G1.3 |
| SYNC-012 | Treat Sign Out, Clear Local Data, and Delete Account as distinct authenticated operations with distinct consequences. | Round 2 Decision 3 | P1/P8 | Implemented in domain, secure adapters and account/data safety UI; live backend verification pending | G1.1/G1.3/G8.1 |
| SYNC-013 | Restore synchronized history safely after the same account signs back in, without exposing it to any other account. | Round 2 Decision 3 | P1 | Planned | G1.3 |

## Food catalog and meal tracking

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| FOOD-001 | Provide offline-searchable Pakistani foods and recipes to free users without AI. | Decisions 3/5 | P2 | In implementation: foods complete, recipes pending | G2.1 |
| FOOD-002 | Record legally usable source attribution, source version, review state, reviewer, and effective dates. | Decision 5 | P2/P3 | Implemented contract; production approvals pending | G2.1/G3.1 |
| FOOD-003 | Support household units such as roti, katori, glass, serving, piece, grams, and millilitres with explicit conversions/ranges. | Decision 3 | P2 | Implemented | G2.1 |
| FOOD-004 | Support regional serving variants and prepared recipe versions. | Decision 5 | P2/P3 | Implemented locally: recipe catalog, immutable logging and selection UI; content approval pending | G2.1 |
| FOOD-005 | Support admin-managed foods/recipes and versioned catalog publication. | Decision 5 | P3 | In implementation: approved food/recipe import plus immutable draft/review/approve/publish/revoke contract with provenance and four-eyes controls verified; server persistence/admin UI pending | G3.1 |
| FOOD-006 | Support user-created custom foods and recipes without contaminating the approved catalog. | Decision 5 | P2 | Local acceptance implemented: custom foods and isolated custom-recipe composition/persistence/search/logging; owner/device acceptance pending | G2.1 |
| FOOD-007 | Support offline “food not found” notes for later resolution. | Decision 5 | P2 | Implemented locally: offline entry, persistence and sync staging | G2.1 |
| FOOD-008 | Allow editable meal type, timestamp, item, quantity, unit, recipe, and oil assumptions before save. | Master §6 + Decision 3 | P2 | In implementation: meal type/time, food/custom-food quantity/unit, recipe serving, proportional correction quantities, approved/custom food and approved/custom recipe replacement, exact-release food unit switching and oil-assumption correction complete | G2.1 |
| FOOD-009 | Recalculate deterministic calories and macros from catalog values and quantities. | Decision 3 | P2 | Implemented | G2.1 |
| FOOD-010 | Distinguish recipes whose nutrient totals include oil from oil-excluded bases to prevent double counting. | Decision 3 | P2 | Implemented in recipe domain and V6 persistence | G2.1 |
| FOOD-011 | Label oil/sauce adjustments as estimates, show their basis, and permit user correction/disablement. | Master §7.2 + Decision 3 | P2 | In implementation: auditable included/excluded/unknown assumption correction complete without fabricated calories; sourced quantitative additions pending | G2.1 |
| FOOD-012 | Do not ship kitchen/dish multipliers as validated accuracy claims before calibration and review. | Decision 4 | P2 | Gated | D-004 |
| FOOD-013 | Show daily calories, protein, carbohydrates, fat, water, meals, and progress against configurable goals. | Master §6 | P2 | In implementation: logged totals and provisional onboarding-goal progress complete; reviewed configuration/adjustment pending | G2.1 |
| FOOD-014 | Preserve raw user input separately from normalized, versioned nutrition calculations. | Audit prerequisite | P2 | Implemented | G2.1 |

## AI logging and blueprint

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| AI-001 | Route all Gemini calls through a trusted backend; never embed provider secrets in the app. | Master §10 + security decision | P4 | HTTPS Firebase ID/App Check client boundary verified with no provider secret; deployed backend pending | G4.1 |
| AI-002 | Support Pakistani Roman Urdu, English, and mixed text meal parsing. | Master §7.1 | P4 | Planned | G4.1 |
| AI-003 | Add voice transcription using the same reviewed meal-matching pipeline. | Master §6 | P4 | Planned | G4.2 |
| AI-004 | Return structured candidates, confidence, ranges, assumptions, and catalog match IDs rather than authoritative nutrient totals. | Decision 3 | P4 | Local structured-candidate contract verified; range/provider integration pending | G4.1 |
| AI-005 | Require user confirmation before saving uncertain AI estimates. | Decision 3 | P4 | Explicit review/selection and unsaved-draft boundary verified locally | G4.1 |
| AI-006 | Calculate nutrition deterministically from approved catalog records after AI matching. | Decision 3 | P4 | Exact approved-catalog resolution into deterministic meal draft verified locally | G4.1 |
| AI-007 | Preserve model, prompt, schema, catalog, and calculation versions with each accepted result. | Audit prerequisite | P4 | Immutable local event/sync provenance and deterministic calculation versions verified; server retention verification pending | G4.1 |
| AI-008 | Enforce quotas, abuse controls, safety rules, request size, timeouts, and cost ceilings server-side. | Monetization/security | P4/P5 | Client request/timeout/response limits, quota response and authenticated credit-reservation boundaries verified; atomic server enforcement pending | G4.1/G5.1 |
| AI-009 | Provide safe retry/fallback and never lose the user’s original text or recording state. | UX requirement | P4 | Planned | G4.1/G4.2 |
| AI-010 | Provide photo plate analysis as a paid feature with confidence and confirmation. | Master §6 | P8 | Planned | G8.1 |
| AI-011 | Do not claim sub-800 ms or on-device “edge AI” unless measured and actually implemented. | Architecture correction | P4 | Planned | G4.1 |

## Hydration, fasting, and health-plan support

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| HLTH-001 | Support manual hydration logging and configurable reminders offline. | Master §6/7.6 | P2 | In implementation: offline logging and revisioned reminder preferences complete; Android notification delivery/verification pending | G2.1 |
| HLTH-002 | Treat hydration targets as configurable wellness estimates and support clinician-provided restrictions. | Decision 1/4 | P2/P7 | Implemented locally: optional user/clinician target, provenance, restriction context and no-target state; owner/device acceptance pending | G7.1 |
| HLTH-003 | Do not ship a universal weight×35+500 prescription as clinically validated. | Decision 4 | P7 | Gated | D-005 |
| HLTH-004 | Track estimated carbohydrate and sodium totals without claiming measured glucose response. | Decision 1/4 | P2/P7 | Planned | G7.1 |
| HLTH-005 | Make thresholds configurable and identify whether they came from the user, clinician, or general guidance. | Decision 1 | P7 | Planned | G7.1 |
| HLTH-006 | Support Ramadan, Sunnah, and intermittent fasting schedules. | Master §5/6 | P6 | Domain, encrypted persistence and settings UI implemented with explicit UTC windows, source/offset metadata and sync staging; prayer calculation pending | G6.1 |
| HLTH-007 | Use selected-city coordinates by default, optional precise permission, selectable calculation method, and manual minute adjustment. | Master §4/7.5 | P6 | Domain boundary implemented with coordinate provenance, reviewed method/version metadata, bounded manual adjustments and fixture gate; approved data/method/engine and UI integration pending | G6.1 |
| HLTH-008 | Suppress daytime food reminders and provide configurable Suhoor/Iftar reminders during an active religious fast. | Master §7.5 | P6 | Policy implemented: suppression only in eligible active window; Suhoor/Iftar opt-ins respected; device scheduling/delivery pending | G6.1 |
| HLTH-009 | Never encourage fasting when user-provided/clinician instructions contraindicate it; show conservative safety escalation. | Safety prerequisite | P6/P7 | Domain policy implemented: pregnancy/breastfeeding/minor block; diabetes/BP/clinician plan require guidance and block automation/reminders; reviewed copy/UI pending | G6.1/G7.1 |
| HLTH-010 | Support imported or manually entered wellness/medical meal plans while preserving the original. | Decision 1 | P7 | Immutable manual/pasted/local `.txt`/`.md` capture and list UI plus encrypted owner-scoped persistence/outbox implemented; Android picker verification pending | G7.1 |
| HLTH-011 | Support adherence tracking, meal swaps, and credit-based AI regeneration with explicit approval. | Other confirmed requirements | P7 | Exact revision-linked adherence/correction UI, neutral 7/30/90-day reports, privacy-default export, explicit approval and plan revisions implemented; swaps and entitlements pending | G7.1 |
| HLTH-012 | Support optional health-plan reminders without silently enabling notifications. | Other confirmed requirements | P7 | Opt-in owner-scoped encrypted preference model, weekday/time UI and sync staging implemented; permission flow and native delivery pending device review | G7.1 |

## Reports

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| RPT-001 | Generate a user-controlled 7/14/30-day PDF summary suitable for sharing/printing. | Master §6/7.4 | P7 | Planned | G7.2 |
| RPT-002 | Clearly label user-entered data, estimates, missing days, and AI-derived values. | Safety prerequisite | P7 | Planned | G7.2 |
| RPT-003 | Do not call adherence “clinical compliance” or the PDF a validated clinical audit without professional approval. | Decision 4 | P7 | Gated | D-006 |
| RPT-004 | Keep export local/user-initiated by default and avoid public links containing health data. | Privacy prerequisite | P7 | Planned | G7.2 |

## Feed and administration

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| ADM-001 | Build a separate secure web administration application. | Decision 6/Other | P3 | Planned | G3.1 |
| ADM-002 | Use staff identity, role-based permissions, MFA policy, audit logs, and least privilege. | Security prerequisite | P3 | In implementation: action-level role matrix, MFA gate, inactive-staff rejection, four-eyes approval/publication and append-only audit contract verified locally; server identity/persistence and security acceptance pending | G3.1 |
| ADM-003 | Manage foods, recipes, units, sources, review status, and catalog releases. | Decision 5 | P3 | In implementation: versioned food/recipe/source import and audited catalog release workflow verified locally; editor UI and server-transaction persistence pending | G3.1 |
| ADM-004 | Manage grocery prices with city, market, commodity, unit, source, status, and last-updated date. | Decision 6 | P3 | In implementation: complete price evidence model plus MFA/four-eyes/audited publication and freshness gate verified; server persistence, approved source and admin UI pending | G3.1 |
| ADM-005 | Manage scheduled quotes/health facts with draft, review, publication, expiry, locale, and category. | Other confirmed requirements | P3 | In implementation: sourced health-fact/quote model plus locale/category/schedule/expiry and audited MFA/four-eyes workflow verified; server/admin UI pending | G3.1 |
| ADM-006 | Manage launch and future city records as versioned configuration without requiring a mobile code release. | Round 2 Decision 5 | P3 | In implementation: versioned runtime contract, verification/fallback, rollback-safe last-known-good cache and audited four-eyes workflow complete; server persistence, signature implementation, fetch/startup wiring pending | G3.1 |
| FEED-001 | Show an authenticated combined timeline and category tabs. | Other confirmed requirements | P3 | Presentation/controller and conditional authenticated-shell destination implemented with verified-owner reactions and category filters; server repository/root composition pending | G3.2 |
| FEED-002 | Support zero or 2–4 scheduled posts on a day; do not require artificial daily filler. | Other confirmed requirements | P3 | Domain rule implemented and tested: zero or two-to-four accepted; one or more than four rejected | G3.2 |
| FEED-003 | Allow one private like/dislike reaction per user/post without exposing identity publicly. | Other confirmed requirements | P3 | Controller/UI contract implemented: one owner/post reaction, replace/remove semantics, failure preservation and no public identity/count rendering; server rules pending | G3.2 |
| FEED-004 | Keep health facts source-attributed and reviewable; do not publish unreviewed medical claims. | Decision 4 | P3 | Domain/publication rule implemented: source ID/citation mandatory and visibility requires independent reviewed publication within schedule | G3.1 |

## Bachat

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| BCH-001 | Provide useful non-AI grocery planning to free users. | Decision 6 | P6 | Deterministic planning domain, repository boundary, GetX controller and responsive UI implemented; production data source pending | G6.2 |
| BCH-002 | Display price source, market/location, unit, and last update; label stale/missing prices. | Decision 6 | P6 | Implemented in price contract and Bachat result cards; stale/missing prices are excluded with explicit unavailable states | G6.2 |
| BCH-003 | Optimize within calories, protein, budget, dietary restrictions, serving/variety bounds, pack sizes, availability, and waste—not protein alone. | Derived correctness | P6 | Implemented in bounded deterministic planner with hard-constraint failure instead of silent relaxation | G6.2 |
| BCH-004 | Never invent live prices or describe stale snapshots as current. | Decision 6 | P3/P6 | Implemented in price presentation contract: missing/draft/future/expired/older-than-seven-day records expose no amount and cannot be labelled current | G3.1/G6.2 |
| BCH-005 | Gate AI personalization through entitlements/credits/rewarded actions while retaining free deterministic utility. | Decision 6 | P5/P6 | Planned | G5.1/G6.2 |

## Monetization

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| PAY-001 | Support configurable recurring plans and AI allowances; do not hardcode product assumptions into clients. | Other confirmed requirements | P5 | Authenticated versioned remote-catalog client and Play-localized price join verified; deployment pending | G5.1 |
| PAY-002 | Support server-verified monthly subscription entitlements. | Master §9 + Other | P5 | Official Play purchase adapter, post-verification completion and owner-bound status refresh implemented; live backend/store proof pending | G5.1 |
| PAY-003 | Support server-verified consumable AI credit top-ups. | Other confirmed requirements | P5 | Consumable Play launch and server-reconciliation boundary implemented; live backend/store proof pending | G5.1 |
| PAY-004 | Support explicitly chosen rewarded-ad actions that grant defined server-authoritative benefits. | Master §9 + Other | P5 | Planned | G5.2 |
| PAY-005 | Maintain an immutable credit ledger with reason, idempotency key, source transaction, balance effect, and actor. | Security prerequisite | P5 | Strict backend-response decoding, balance projection, encrypted verified cache and UI history verified; transactional backend pending | G5.1 |
| PAY-006 | Verify Play purchases and lifecycle changes on the backend; do not trust client purchase state. | Confirmed security requirement | P5 | Client restore/reconciliation, independent server-state refresh, authenticated HTTPS transport and hostile-response boundaries verified; deployed Play Developer API/RTDN processing pending | G5.1 |
| PAY-007 | Keep historical entitlements usable during temporary offline periods without allowing offline credit minting. | Offline/payments requirement | P5 | Bounded offline grace, encrypted owner-bound verified-state cache and online-only reservation verified locally; backend/device proof pending | G5.1 |
| PAY-008 | Keep exact plans, prices, credits, quotas, and feature gates remotely configurable and versioned. | Other confirmed requirements | P5 | Strict remote product/credit/feature catalog client and non-fabricated Play price boundary verified locally; deployed source pending | G5.1 |

## Privacy, security, quality, and operations

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| SEC-001 | Classify profile, health, meal, voice, image, billing, and analytics data; collect only what is necessary. | Safety prerequisite | P0 | Planned | G0.1 |
| SEC-002 | Obtain explicit consent for AI processing and explain whether raw text/audio/images leave the device. | Safety prerequisite | P4 | Planned | G4.1/G4.2 |
| SEC-003 | Define retention/deletion for raw media, transcripts, AI requests, logs, exports, and deleted accounts. | Safety prerequisite | P0/P4 | Planned | G0.1/G4.1 |
| SEC-004 | Enforce per-user cloud access rules, backend authorization, App Check/attestation, rate limits, and secret isolation. | Architecture | P1/P4 | Planned | G1.1/G4.1 |
| SEC-005 | Provide data export, cache clearing, sign-out, and account deletion. | Master §6 | P1/P8 | Planned | G1.1/G8.1 |
| SEC-006 | Keep operational logs free of raw health content and secrets by default. | Safety prerequisite | P0+ | Implemented locally: production diagnostics are silent and debug diagnostics accept bounded event identifiers only; telemetry-provider policy/review pending | Every gate |
| SEC-007 | Define analytics consent and prohibit advertising profiles based on sensitive health attributes. | Safety prerequisite | P0/P5 | Planned | G0.1/G5.2 |
| QA-001 | Use unit, widget, integration, security-rule/emulator, contract, sync, and end-to-end tests appropriate to each module. | Quality prerequisite | All | In implementation: local unit/widget/integration coverage includes atomic failed-migration rollback and retry; backend rules/emulator and device-wide evidence pending | Every gate |
| QA-002 | Verify accessibility, text scaling, keyboard/screen reader behavior where applicable, low-end Android performance, and offline recovery. | Quality prerequisite | All | In implementation: health-plan small-screen/200%-text widget evidence and semantic weekday/range labels complete; device-wide verification pending | Every gate |
| OPS-001 | Add environment separation, automated builds, crash reporting, privacy-safe telemetry, release rollback, and data migration procedures. | Operations prerequisite | P0/P1 | Planned | G0.2/G1.3 |

## V2 family and caregiver vision

| ID | Requirement | Source | Phase | Status | Verification |
|---|---|---|---|---|---|
| FAM-001 | Support multiple family profiles with explicit subject attribution. | Master §8 | V2 | V2 | Future gate |
| FAM-002 | Provide caregiver grants rather than shared passwords or implicit access. | Master §8 + safety | V2 | V2 | Future gate |
| FAM-003 | Support remote family synchronization, profile-specific reports, medication reminders, and family subscriptions. | Master §8 | V2 | V2 | Future gate |
| FAM-004 | Add consent, guardianship/dependent rules, revocation, and audit history before family data sharing. | Safety prerequisite | V2 | V2 | Future gate |
