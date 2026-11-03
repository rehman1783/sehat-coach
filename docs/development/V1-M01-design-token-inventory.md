# V1-M01 design token inventory

This inventory is the implementation source of truth for new Sehat Coach UI. Figma remains the visual reference; approved requirements remain the behavioral source of truth.

## Color roles

| Role | Token | Current value |
|---|---|---|
| Brand/action | `AppColors.primaryGreen` | `#0C4E2B` |
| Strong action | `AppColors.darkGreen` | `#0F4725` |
| Accent | `AppColors.graphiteYellow` | `#F59E0B` |
| App background | `AppColors.background` | `#F6F8F6` |
| Surface | `AppColors.surface` | `#FFFFFF` |
| Border | `AppColors.border` | `#D5E3DA` |
| Primary text | `AppColors.textPrimary` | `#0A301A` |
| Secondary text | `AppColors.textSecondary` | `#5E7568` |
| Warning | `AppColors.warningAmber` | `#E55319` |
| Error | `AppColors.errorRed` | `#EE4343` |

## Typography

- Dela Gothic One: display headings, major titles, and brand moments.
- Inter: body copy, labels, controls, inputs, and data.
- Use the theme text styles or `AppTypography`; do not introduce another font family without a recorded design decision.

## Layout and shape

- Spacing scale: 4, 8, 12, 16, 24, 32, and 48 logical pixels.
- Radius scale: 8, 12, 16, and 24 logical pixels; `999` is reserved for pills.
- Minimum interactive target: 48 × 48 logical pixels.
- Phone-first content maximum: 560 logical pixels, centered on wider canvases.
- Compact breakpoint: below 600 logical pixels. Expanded breakpoint: 1024 logical pixels and above.

## Motion

- Quick feedback: 160 ms.
- Standard transition: 280 ms.
- Emphasized reveal: 520 ms.
- Motion must communicate state, remain non-blocking, and avoid indefinite decorative movement.
- A reduced-motion application policy remains part of launch hardening.

## Usage rule

New components must use these tokens unless a Figma-specific exception is documented. Existing onboarding magic values may be migrated during visual corrections, but approved content and behavior must not change as a side effect.
