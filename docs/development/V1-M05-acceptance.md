# V1-M05 local acceptance record

Date: 22 October 2026  
Status: Partial local acceptance; module remains in implementation

## Verified locally

- `flutter analyze` completes with no issues across the repository.
- `flutter test` completes with all 213 tests passing.
- Encrypted Drift schema migrates from the V1 fixture through V5 while preserving existing records, outbox metadata and cursors.
- Approved-release food search covers English, Roman Urdu and localized synonyms, literal wildcard handling and draft/review exclusion.
- Meal and water mutations commit typed records and sync-outbox operations atomically; injected late failures roll back the whole mutation.
- Daily meal and water projections react to offline writes, respect local-day UTC offsets and isolate owners.
- Meal corrections preserve immutable history and reject stale or competing edits.
- Dashboard, meal logging, correction and water controllers cover loading, empty, error and retry behavior.
- Existing onboarding widget/integration tests remain green.
- The bounded Drift/ObjectBox desktop comparison and encryption proof remain recorded in ADR-001.

## Not accepted yet

- Recipe domain calculation, explicit oil semantics, V6 catalog persistence/import, approved-release offline search, V7 immutable meal-event logging and recipe selection UI are implemented; approved production content and owner visual acceptance remain open.
- Custom-food creation/search/logging and offline “food not found” capture are implemented. V10 custom-recipe composition, persistence, immutable ingredients, separated search, sync staging and meal logging are implemented without contaminating the approved catalog.
- Daily dashboard progress now compares logged calorie and macro ranges with the user’s provisional onboarding planning estimate. It suppresses automatic targets for pregnancy, breastfeeding and clinician-plan profiles, and does not promise dates or outcomes. Clinically approved target-adjustment rules remain open.
- V11 weight check-ins are stored offline as owner-scoped immutable events with atomic sync staging. Metric/imperial entry, recent active history, neutral start-to-personal-target direction and immutable correction-by-supersession are implemented; device/accessibility acceptance remains open.
- V12 hydration preferences support an explicit no-target state and optional user- or clinician-sourced targets with visible provenance and restriction context. Notification scheduling/delivery remains open and is not simulated.
- V13 hydration reminder preferences persist an optional local window and interval. The interface states that device notifications are not active; Android permission/scheduling/reboot/timezone delivery remains deferred.
- Production Pakistani nutrition/catalog data has no approved source, licence and reviewer package; all test data remains synthetic.
- Real authentication activation is blocked on approved provider/project configuration. Preview mode must not be treated as an authenticated app session.
- Android 10+ profile-mode startup, encrypted import/search/dashboard timing, memory and file-size evidence remains pending by product-owner direction.
- Representative-device accessibility checks, screen-reader/focus behavior, large text, keyboard and visual owner acceptance remain pending.
- Immutable correction now supports proportional portion changes, replacement across approved foods, owner-scoped custom foods, approved recipes and owner-scoped custom recipes, exact-release food serving-unit switching, and explicit included/excluded/unknown oil-assumption metadata while preserving frozen source/calculation evidence. Quantitative oil/sauce additions remain open pending sourced conversion data.
- Configurable hydration progress and provisional onboarding calorie/macro progress are displayed with source/safety wording; professionally reviewed goal adjustment constraints remain gated.

## Decision

Do not mark V1-M05 complete. Continue with recipes and remaining offline tracker requirements, then rerun this gate. External authentication, catalog approval and Android/device verification remain explicit dependencies rather than reasons to fabricate production behavior.
