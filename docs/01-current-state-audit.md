# Repository baseline and gap audit

Baseline date: 18 October 2026

## Executive assessment

The repository is a useful **UI/onboarding prototype**, not a production foundation. It contains Flutter screens, theme work, generated Figma references, a preliminary onboarding model and calorie calculator, a location prototype, and a very small test surface. It does not yet contain the approved state architecture, durable offline database, authentication, synchronization, food catalog, admin backend, AI controls, or production operations.

## Existing assets worth preserving

- Flutter targets for Android, iOS, web, desktop, and tests.
- Splash and multi-step onboarding UI prototypes.
- Preliminary theme and reusable visual ideas.
- Figma-derived PNG/SVG/PDF references, including splash and biometrics concepts.
- Initial onboarding domain types and calculation experiments.
- Detailed strategy documents with 116 traced requirements.

## Prototype limitations that must not become accidental architecture

| Area | Current observation | Required disposition |
|---|---|---|
| State | Mutable onboarding state; no feature-level GetX controllers yet | Replace behind tested domain/use-case boundaries |
| Persistence | No Drift/ObjectBox implementation | Benchmark, select, then add repository-backed encrypted local storage |
| Sync | No outbox, tombstones, versions, or conflict rules | Build as a foundation capability before broad feature work |
| Auth | No production account lifecycle | Add age gate, sessions, account isolation, sign-out recovery, deletion separation |
| Nutrition | Hard-coded `1.35` activity factor and fixed calorie adjustments | Replace with reviewed rules and explicit inputs/exclusions |
| Conditions | UI/controller behavior is effectively single-select | Implement approved multi-select semantics and safety consequences |
| Location | Insecure HTTP fallback and broad international city lists | Remove insecure transport; use admin-configured V1 city catalog |
| UI | Fixed-size/generated layouts and multiple ad-hoc fonts | Convert approved references into tokens and responsive components |
| Claims | Exact dates and unapproved copy appear in prototypes | Route all consequential claims through reviewed content/constants |
| Tests | Only minimal widget coverage | Establish unit, repository, sync, widget, integration, security, and migration suites |

## Known code-level issues for the first review backlog

- `OnboardingState.copyWith` does not fully represent/preserve all state, including language.
- Condition selection overwrites the list instead of supporting multiple selections.
- Activity level, target weight, goal pace, pregnancy/breastfeeding exclusion, and clinician-plan override are not modeled adequately.
- Location detection calls `http://ip-api.com/json`; production network traffic must use secure transport.
- The location repository contains locations outside the approved Pakistan V1 launch model.
- The root `index.html` is a separate Tailwind prototype and is not the Flutter web application entry point.
- `android/gradle.properties` is already modified locally and must be preserved until its ownership is clarified.

## Verification baseline

`flutter analyze` could not resolve dependencies because the project requests Dart `^3.13.3` while the installed SDK is `3.9.2`. The Flutter tool suggested Flutter `3.47.7`. No SDK upgrade or constraint downgrade was performed. Tests are therefore **not currently verified**.

## Baseline conclusion

Retain the visual and product learning, but treat existing feature code as prototype input subject to module review. Do not build cloud, AI, or monetization features on top of the current state model before V1-M01/V1-M02 establish the toolchain, architecture boundaries, data ownership, and test harness.

