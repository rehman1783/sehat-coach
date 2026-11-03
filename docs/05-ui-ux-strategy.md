# UI/UX strategy

## Design-source assessment

The available Figma link, generated HTML, PNGs, SVGs, and PDFs provide a credible visual direction, especially for splash, biometrics, gradients, glass-like cards, and onboarding tone. They do not yet form a complete responsive product specification. Many exports are fragmented layers, fixed-size compositions, or duplicated formats.

## How the ten designed screens should be used

1. Extract a small token set: colors, typography roles, spacing, radii, elevation, gradients, motion, and icon rules.
2. Build Flutter primitives before reproducing whole screens.
3. Convert each reference into a state specification: default, loading, validation error, permission denied, offline, empty, large text, keyboard open, and retry.
4. Validate at small Android, typical Android, large Android, and iPhone dimensions; do not preserve fixed Figma coordinates.
5. Extend the same component language to undesigned screens instead of copying screenshots or generated Tailwind markup.

## Required component families

- App shell, safe-area layout, navigation, and responsive content frame.
- Buttons, links, chips, segmented selectors, fields, sliders, pickers, and validation messages.
- Metric/summary cards, progress states, charts, list rows, food/meal cards, and skeletons.
- Consent, warning, uncertainty, clinician-plan, offline, sync-conflict, and destructive-action patterns.
- Bottom sheets, dialogs, snackbars, banners, permission rationale, and recovery flows.
- Accessible semantic labels, focus order, touch targets, contrast, text scaling, and reduced motion.

## Screen acceptance packet

Each screen is accepted only with:

- link/name of the reference frame and mapped requirement IDs;
- component/token mapping rather than one-off styling;
- responsive screenshots at agreed device sizes;
- light/dark behavior if supported, plus Urdu/long-text resilience;
- keyboard, scroll, notch, and system text-scale behavior;
- all error/offline/empty/loading states;
- widget/golden tests where stable;
- owner sign-off for material visual deviations.

## Current design risks to correct

- Multiple font families without a defined role system.
- Fixed `w-96`/absolute positioning in generated web code.
- Exact target-date promises and unreviewed health copy embedded in mockups.
- Missing or fragmented icons/assets and inconsistent labels.
- City chips and other content that can diverge from the approved configurable list.
- Pixel-perfect imitation taking precedence over accessibility or platform behavior.

## Design decision

Use Figma as the visual reference, Flutter components/tokens as the implementation source of truth, and the traceability matrix as the behavioral source of truth.

