# Quality and release gates

## Definition of done for any module

A module is complete only when its requirements are traced to implementation and tests, migrations are safe, negative/offline states pass, no open P0/P1 defect remains, required external approvals are recorded, and the control board links the evidence.

## Automated test layers

- **Domain unit tests:** calculations, exclusions, goals, pricing freshness, permissions, conflict policies.
- **Repository tests:** transactions, encryption boundaries, account scoping, failures, retries, and migrations.
- **Sync tests:** duplicate delivery, reordering, interruption, conflict, tombstones, clock skew, and partial failure.
- **Widget/golden tests:** reusable components and critical states, not brittle screenshot coverage of everything.
- **Integration tests:** onboarding, offline logging, reconnect/sync, sign-out with pending data, account switch, restore, deletion.
- **Backend/security tests:** authorization rules, role boundaries, audit logs, abuse limits, replay/idempotency.
- **Performance tests:** cold start, food search, bulk import, dashboard reactive queries, sync queue, memory, and low-end Android behavior.

## Safety and trust gates

- Nutrition estimates show inputs, estimation language, and reviewed bounds.
- Pregnancy/breastfeeding, minors, clinician-plan precedence, and special-medical-condition exclusions are tested.
- AI output has confidence/fallback behavior and cannot silently become clinical truth.
- Prices disclose source, unit, city, and last-updated date and never fabricate absence.
- Destructive actions are distinct: Sign Out, Clear Local Data, Delete Account.
- No account data crosses identity boundaries; unsynced records are protected explicitly.
- Trusted storage identities include both the exact application environment and Firebase project scope before hashing, preventing the same UID from sharing an encrypted database or protected key across development, staging or production even when a project is shared.
- Storage identity derivation rejects oversized owner IDs and embedded scope delimiters before any file or protected-key operation.
- Upgrades from project-only or unscoped storage identities preserve the encrypted database, key and synchronization state; ambiguous legacy artifacts or aliases fail closed without overwrite or deletion.

## Release checklist categories

1. Functional acceptance and regression suite.
2. Data migration, backup/recovery, and rollback rehearsal.
3. Security review, secret scan, dependency review, and platform hardening.
4. Privacy inventory, consent/copy, retention, export, and deletion verification.
5. Clinical/content approval records and versioned rules.
6. Accessibility audit and representative-device testing.
7. Performance budgets and offline/network-degradation testing.
8. Crash/error monitoring, alert ownership, support/admin runbooks.
9. Store metadata, permissions, policy declarations, and staged rollout plan.

Compile-time `APP_ENV` must be omitted only for local development or exactly equal `development`, `staging` or `production`. Unknown values fail closed before cloud or private-storage startup; release consumer builds additionally require `production`.

Firebase compile-time identifiers must be present, bounded and free of whitespace/control characters. The project ID must match Firebase's lowercase letter/digit/hyphen and 6–30 character rules before SDK initialization or local-storage namespace derivation.

Trusted backend build URLs must be at most 2048 characters and use HTTPS with a host and nonzero port. Embedded credentials, queries and fragments are prohibited; transport gateways validate the parsed URI again when composed.

## Baseline command gate

The minimum local verification command set includes formatting, `flutter analyze`, unit/widget tests, and module-specific integration tests. On 22 October 2026 the current Flutter/Dart toolchain resolved the project successfully, repository-wide analysis reported no issues, and all 213 tests passed. This is local automated evidence only; it does not satisfy Android/device, accessibility, security, clinical/content or product-owner acceptance gates.

CI additionally compiles a debug APK from the real production consumer entry point without launching a device. This compile gate does not replace a signed release bundle, Firebase/App Check configuration, representative Android execution or store-track testing.

## Android production identity and signing

Release Gradle tasks fail before packaging while the placeholder application ID or debug/absent signing configuration remains. Copy `android/key.properties.example` to the ignored `android/key.properties`, choose the permanent Play Console application ID, and reference the private upload keystore. Do not commit `key.properties`, `.jks` or `.keystore` files. Register the same final application ID and signing fingerprints in Firebase/Google OAuth before generating the release configuration.

The production consumer bundle command is:

```powershell
flutter build appbundle --release -t lib/consumer_main.dart `
  --dart-define=APP_ENV=production `
  --dart-define=ENABLE_TRUSTED_ACCOUNT_RUNTIME=true `
  --dart-define-from-file=<ignored-production-defines.json>
```

The define file must contain only non-secret client configuration and HTTPS endpoint locations. Server credentials and service-account keys must never be shipped in the app.

The main release manifest grants only `android.permission.INTERNET`, rejects cleartext traffic and disables Android cloud backup/device transfer for root files, databases, preferences and external app data. This protects encrypted health records from being restored outside the account/key lifecycle. Adding any Android permission or backup domain requires a documented privacy/security review and an update to the manifest regression test.

The Android host applies `FLAG_SECURE` in release builds so sensitive screens do not appear in screenshots, screen recordings or recent-app previews. Debug builds remain capturable for controlled UI verification. Representative Android release verification is still required before store submission.

The consumer executable also validates configuration before Firebase or account storage starts. Release mode requires `APP_ENV=production`, trusted account runtime, and a valid non-empty `GOOGLE_SERVER_CLIENT_ID`; optional OAuth client identifiers cannot contain whitespace or exceed the bounded client length. Missing or malformed values stay on the generic fail-closed startup screen.

`dart run tool/verify_no_secrets.dart` is a required local and CI gate. It rejects private signing material, server/service-account credentials, recognized provider tokens, local environment files and production define files from the source tree. A clean scan does not replace provider-side secret rotation or repository-history scanning before release.

Direct dependencies must use bounded hosted or Flutter-SDK sources; Git/path packages and dependency overrides require an explicit policy change and security review. CI actions are pinned to immutable commits with read-only repository permission. Dependabot monitors Pub, Gradle and GitHub Actions weekly, but proposed updates still require compatibility, migration and regression review before merge.

Compatible dependency refreshes must regenerate Drift artifacts and pass schema/migration, encrypted-database, repository, analysis, secret-scan and full regression gates. Major package updates stay isolated for explicit API/UI migration review.

Every local schema upgrade must be atomic. A failed migration must retain the previous schema version, records and index/table set so a corrected app can retry against the original database; failure-injection evidence is required whenever the migration chain changes.

Before an upgrade transaction commits, it must pass SQLite foreign-key validation. Orphaned legacy health/catalog rows fail closed without advancing the schema version or exposing a partially upgraded database; recovery must preserve the original file for an explicit repaired retry.

Every encrypted account activation must verify the key/schema and pass a bounded SQLite integrity check before repositories receive the database. Corrupt files are closed and preserved for explicit recovery; the app must never silently replace damaged health history with an empty database.

When protected local history cannot open, user-facing errors must state that it was preserved and must not recommend Clear Local Data as the default recovery. Technical/key/file details remain private; retry and support guidance precede any explicit recovery/export decision.

Local-data removal covers the encrypted main database plus SQLite WAL, shared-memory and rollback-journal sidecars. Sidecars are removed before the main file, and protected keys are deleted last so interrupted cleanup cannot silently strand a database without its recovery key.

If an encrypted account file exists but its protected key is absent or malformed, activation must not generate a replacement key or open an empty account. The file remains unchanged, no owner becomes active and the preserved-data recovery guidance is shown.

Account database filenames must not contain raw or reversibly encoded identity. Legacy names migrate to deterministic hashed names without changing the protected key or database content; sidecars move first, the main file moves last and ambiguous collisions fail closed.

Legacy filename migration must never merge or overwrite conflicting SQLite artifacts. A source/destination collision or rename failure preserves every file, activates no owner and enters the same privacy-safe recovery-required UX used for lost keys and corrupt databases.

All local owner-scoped identifiers—database filenames and protected key aliases—derive from one shared, deterministic, one-way digest of the exact authenticated owner ID. Blank or normalized/modified identities are rejected rather than mapped to another account.

Runtime diagnostics accept only bounded event codes. They are disabled in production and cannot carry exceptions, URLs, tokens, identities, profile fields or health payloads. Connecting a crash/telemetry provider remains an external release task and requires approved consent, retention, redaction and environment-separation rules.

Password entry disables suggestions, autocorrect, personalized keyboard learning and smart punctuation, while retaining password-manager autofill and paste support. Password values are transient and must be cleared from visible fields and controller state after each account attempt or authentication-mode exit.

