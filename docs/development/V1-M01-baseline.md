# V1-M01 development baseline

Codex is the current implementer and reviewer. Antigravity handoff is optional for later work.

## Work completed

- Device Preview is opt-in for development via `--dart-define=ENABLE_DEVICE_PREVIEW=true`. Development uses the disclosed preview unless `--dart-define=ENABLE_TRUSTED_ACCOUNT_RUNTIME=true` is set; production always requires an injected trusted application root and fails closed when it is absent.
- Local `.cache/` output is ignored by Git.
- Android minimum SDK is explicitly set to API 29 (Android 10), including launcher-icon configuration.
- Flutter 3.47.7 / Dart 3.13.5 is installed and satisfies the declared SDK constraint.
- Splash location lookup can be injected for deterministic widget testing; the insecure HTTP geolocation endpoint was removed.
- The splash widget test now checks its actual onboarding action and resolved location.
- Splash, goal selection, and biometrics now share the approved Figma typography, green/gold palette, rounded controls, and vector icon language.
- Reusable onboarding option cards expose button and selected semantics for accessibility.
- Goal, kitchen, biometrics, and health-condition screens now use the shared heading and vector icon language.
- Health conditions support multiple relevant selections; Standard Routine is mutually exclusive. Controller tests cover selection, exclusivity, and deselection.
- V1 location selection is constrained to the ten approved Pakistan launch cities plus Other city, with a repository test locking the list.
- Coach selection uses the shared Figma typography, vector icon treatment, and accessible selected semantics.
- City selection is an editable autocomplete: typing filters approved cities and also permits a custom city. Labels, choices, and results use lighter typography.
- The ten-screen onboarding UI flow is complete through plan reveal and account-sheet opening.
- Biometrics captures activity level, preferred goal pace, and target weight where relevant.
- Pregnancy, breastfeeding, and clinician-plan selections pause generic calorie estimates; pregnancy and breastfeeding are mutually exclusive.
- The result presents a Mifflin-St Jeor activity estimate with uncertainty language and no guaranteed goal date or match claim.
- End-to-end widget coverage completes the eligible-adult onboarding path at a 390 × 844 logical phone viewport.
- The module control board records V1-M01 as in implementation.
- Shared spacing, radius, breakpoint, touch-target, and motion tokens are defined for new UI.
- A reusable responsive content frame constrains phone-first screens on wide web/tablet canvases.
- Compile-time environment configuration centralizes development, staging, production, and Device Preview behavior without storing secrets.
- CI runs pinned Flutter 3.47.7 formatting, analysis, and tests on pull requests and `main` pushes.
- The design token inventory is recorded in `V1-M01-design-token-inventory.md`.

## Verification gate

On 19 October 2026, `flutter analyze --no-pub` reported no issues and `flutter test --no-pub` passed. V1-M01 remains open for its design token inventory and architecture/configuration conventions.

## Completed implementation slices

1. V1-M01-S01: toolchain and repeatable checks.
2. V1-M01-S02: design token inventory and responsive component baseline.
3. V1-M01-S03: configuration conventions.

The remaining V1-M01 gates are product-owner confirmation of the V1 boundary and the deliberately deferred mobile-device verification. The next code module is V1-M02 app and data foundation.

## Pending device verification

- Android emulator and physical mobile device UI testing is deferred by product-owner direction.
- Before V1 release, verify responsive layouts, touch targets, keyboard behavior, system text scaling, Android 10 compatibility, and representative newer Android versions on mobile devices.
- Until that verification is completed, web screenshots and widget tests are development evidence only and do not establish an exact mobile match to Figma.

## Onboarding content freeze

- Existing onboarding page copy, option labels, explanatory content, and page order are product-owner approved and must not be rewritten during the UI alignment pass.
- UI work may adjust typography, spacing, colors, icons, responsiveness, accessibility, and interaction behavior.
- Copy changes require a new explicit product-owner instruction. Approved eligibility, privacy, and clinical-safety rules still apply where validation is required.
