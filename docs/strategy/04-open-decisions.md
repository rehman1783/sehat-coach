# Open product decisions

These decisions are intentionally unresolved. Do not invent answers inside implementation prompts.

## Closed by Development Decisions Round 2

| ID | Decision | Approved V1 default |
|---|---|---|
| D-002 | Minimum age | Adults 18+; no routine identity documents; future minor pathway remains structurally possible. |
| D-003 | State/database | GetX selected by the product owner on 20 October 2026, superseding Riverpod. The bounded ObjectBox comparison is complete and ADR-001 selects Drift/SQLite for implementation, with repositories shielding domain logic. Android and security verification remain release gates. |
| D-007 | Sign-out data | Successful sign-out removes account-specific sensitive local state after pending-record protection; synchronized cloud history can be restored to the same account. Sign Out, Clear Local Data, and Delete Account remain separate. |
| D-008 | Metabolic estimate | Mifflin–St Jeor plus activity estimate for eligible adults, with ranges/explanations, exclusions, no promised dates, and professionally reviewed safety constraints. |
| D-009 | Launch cities | Karachi, Lahore, Islamabad, Rawalpindi, Faisalabad, Multan, Peshawar, Quetta, Hyderabad, Gujranwala, and configurable Other city. |

Closed decisions must not be reopened during routine implementation. A later change requires an explicit product-owner decision and an impact review.

## Decisions required before P0/P1 completion

| ID | Decision | Why it matters | Recommended default |
|---|---|---|---|
| D-001 | Legal entity, privacy-policy owner, support contact, and initial data-processing jurisdiction. | Required for consent, deletion, vendors, and store publication. | Establish before production Firebase data. |
| D-004 | Nutrition/oil model reviewer, calibration dataset, acceptable error measure, and claim wording. | Core differentiation cannot be marketed as accurate without evidence. | Label as transparent estimates; run weighed-recipe validation. |
| D-005 | Hydration target source, contraindication screen, and adjustment policy. | A universal formula can be unsafe for some users. | User-configurable general estimate; no “precision kidney filtration” claim. |
| D-006 | Name and intended audience of the PDF and whether a clinician will approve it. | “Clinical audit” can overstate validity. | “Nutrition & Lifestyle Summary” until reviewed. |
| D-029 | Qualified reviewer and approved calorie/pace safety constraints, exclusions, and warning wording. | Round 2 approves the estimation approach but explicitly prohibits activating clinically consequential rules before review. | Implement the calculation in inactive/proposal mode; do not enable safety-bound recommendations until approved. |
| D-030 | Offline pending-record recovery mechanism at sign-out. | An encrypted export may introduce more key-management and user-error risk than temporarily blocking sign-out. | Prototype threat model and UX; prefer blocking destructive sign-out unless a recoverable export is demonstrably safe. |

## Decisions required before P2/P3

| ID | Decision | Why it matters | Recommended default |
|---|---|---|---|
| D-010 | Legally usable nutrition sources and licenses. | Food values and redistribution rights are foundational. | Approve sources/licences before importing data. |
| D-011 | Launch catalog coverage target and prioritized dishes. | “Pakistani food support” needs a measurable definition. | Rank dishes from target-user research; publish coverage and no-result rate. |
| D-012 | Language scope: English UI, Roman Urdu UI, Urdu script, or content-only variants. | Impacts layout, localization, QA, and admin content. | English + Roman Urdu V1; plan RTL Urdu separately. |
| D-013 | Admin technology, deployment, staff provider, initial owner provisioning, and MFA standard. | Privileged data cannot launch safely without it. | Web app with separate staff authorization and audited owner bootstrap. |
| D-014 | Grocery price collection process, update cadence, expiry rules, and reviewer responsibility per city. | Determines whether Bachat information is trustworthy. | Manual approved snapshots with explicit freshness status. |
| D-015 | Editorial policy and sources for health facts/quotes. | Scheduled content can create medical misinformation or licensing issues. | Source required for health facts; two-person review for sensitive content. |

## Decisions required before P4/P5

| ID | Decision | Why it matters | Recommended default |
|---|---|---|---|
| D-016 | AI provider model(s), data-use/retention terms, region, and fallback. | Health-related text/audio/image data is sensitive and cost-variable. | Provider abstraction; zero/minimal provider retention where contractually available. |
| D-017 | Raw voice/photo retention and whether users may opt in to improvement datasets. | Drives consent, storage cost, and privacy risk. | Delete after processing by default; separate explicit opt-in for any reuse. |
| D-018 | AI evaluation thresholds and human escalation path. | “Works in Roman Urdu” needs measurable quality. | Curated test set; ship only with defined acceptance/edit/rejection thresholds. |
| D-019 | Subscription products, allowance renewal, credit expiry, refund/failure charging, rewarded grants, and grace periods. | Required for ledger semantics and user trust. | Remotely configured; reserve then settle; refund failed provider calls. |
| D-020 | Advertising categories, frequency caps, consent, and health-data separation. | Sensitive health context makes inappropriate targeting particularly risky. | Contextual/non-health-targeted ads only; explicit reward action; strict caps. |
| D-021 | Whether Easypaisa/JazzCash web checkout remains desired for Android digital features. | Store rules, entitlement reconciliation, tax, and support require separate review. | Use Play Billing for Android launch until legal/store-policy review approves alternatives. |

## Decisions required before P6/P7/P8

| ID | Decision | Why it matters | Recommended default |
|---|---|---|---|
| D-022 | iOS release timing and cross-platform entitlement strategy. | Apple Sign-In, billing, and account parity affect backend contracts. | Preserve platform-neutral entitlements; schedule after Android validation. |
| D-023 | Supported fasting calculation methods, default by locale, high-latitude policy, and manual offsets. | Incorrect times undermine trust and may affect safety. | User-visible method and manual correction; Pakistan-oriented default after review. |
| D-024 | Bachat optimization objective priorities and allowed nutritional constraints. | Cheapest-protein-only output is not a safe or usable plan. | Cost subject to hard dietary constraints and variety bounds; explain infeasibility. |
| D-025 | How clinician-provided plans are verified, if at all. | “Clinician-approved” must not be inferred from a user upload. | Separate `user says clinician-provided` from verified reviewer approval. |
| D-026 | Which plan changes count as clinically significant and who may approve them. | Controls AI behavior and safety. | Define with qualified professional/legal review before P7. |
| D-027 | External report sharing mechanism and retention. | Public links and messaging copies can leak health data. | Generate locally and use OS share sheet; no hosted public link in V1. |
| D-028 | Launch/beta success thresholds. | Release scope must be evidence-based. | Define targets for crash-free use, sync success, food coverage, correction, retention, and AI cost before beta. |

## Remaining development blockers

P0 and the bounded database benchmark can begin without another product decision. Production Firebase/auth work requires D-001 plus concrete development/staging project ownership and identifiers. Activating calorie/pace safety constraints requires D-029, but the deterministic estimate service and disabled/excluded flows can be built first. P2 catalog implementation depends on D-004, D-010, and D-011. No clinical claim, hydration prescription, or “doctor audit” label should ship while D-004 through D-006 remain open. The sign-out design can proceed with a safe default that blocks destructive offline completion; D-030 is needed only if portable encrypted recovery is required for V1.
