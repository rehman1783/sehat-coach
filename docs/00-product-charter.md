# Product charter

## Product promise

Sehat Coach is a Pakistan-first, offline-capable nutrition and wellness coach for adults. It should make culturally relevant food logging, hydration, goal tracking, fasting, grocery planning, and clinician-supported nutrition easier without presenting estimates or AI output as medical certainty.

## V1 audience and boundary

- Adults aged 18 and above.
- Pakistan-first localization, foods, portions, languages, prices, and launch operations.
- Ten initial cities plus configurable **Other city**; core logging works everywhere.
- Android 10 (API 29) and newer are supported for V1; older Android releases are outside the supported device range.
- General wellness and clinician-supplied plans, not diagnosis or autonomous treatment.
- Pregnancy, breastfeeding, minors, and special medical circumstances do not receive generic weight-loss calculations.

## Non-negotiable product properties

1. **Offline-first:** logging and recent history remain useful without a connection.
2. **Account isolation:** one account's local data can never appear for another.
3. **Recoverable sign-out:** synced data is restorable; unsynced health data is never silently destroyed.
4. **Explainable estimates:** energy and AI recommendations show their basis, uncertainty, and limits.
5. **Admin-controlled facts:** cities, prices, foods, safety copy, and published content are configurable and auditable.
6. **Human approval where consequential:** medical or clinically meaningful AI suggestions remain gated.
7. **Evidence-based completion:** screens alone do not constitute a finished feature.

## V1 success measures

- A new eligible adult can safely onboard and reach a useful first dashboard.
- A returning user can log common Pakistani meals and water offline with fast search.
- Local changes synchronize without duplication or cross-account leakage.
- A user can understand and correct the inputs behind calorie and macro estimates.
- Grocery prices always disclose city, unit, source, and update date; missing data is shown as unavailable.
- Support/admin users can correct catalog and content data without an app release.
- Crash-free, accessibility, performance, privacy, and synchronization thresholds in the release gates are met.

## Explicitly not promised in early V1

- Exact weight-loss dates or guaranteed outcomes.
- Diagnostic advice, medication changes, or replacement of a clinician.
- Current grocery pricing where no verified feed exists.
- Dependable image-based nutrition without confidence handling and manual correction.
- Minor accounts, caregiver controls, or household sharing before their dedicated safeguards exist.

