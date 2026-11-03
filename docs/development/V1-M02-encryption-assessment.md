# Encryption feasibility — 21 October 2026

Status: isolated desktop encrypted-storage proof passed; production integration and Android validation remain pending. Existing comparison benchmark databases contain synthetic data and are plaintext.

## Drift

The official encryption guide now recommends SQLite3MultipleCiphers build hooks with Drift >=2.32 and sqlite3 3.x. Our benchmark uses Drift 2.31 / sqlite3 2.9, so its performance evidence does not cover that encrypted runtime. Do not assume PRAGMA key on ordinary SQLite encrypts anything. The isolated proof in `tool/encrypted_drift_proof` uses Drift 2.35 and sqlite3 3.7.1 with the sqlite3mc build hook. It checks cipher availability before setting the key.

On Windows, the proof wrote a synthetic record with a random 256-bit key, closed and reopened it with the correct key, and confirmed missing and incorrect keys could not read it. It also passed an additive schema change, transaction rollback, and another reopen. `dart analyze` reported no issues and `dart run run.dart` passed on 21 October 2026. The script retains only a synthetic scratch database under the OS temporary directory for inspection. This proves a desktop integration path, not Android packaging, production key custody, backup behavior, or sign-out safety.

Source: https://drift.simonbinder.eu/platforms/encryption/

## ObjectBox

The installed Dart 5.3.2 Store API inspected for this assessment did not expose a database encryption key parameter. Native database encryption support suitable for this app has not been established. An application-level encrypted payload approach would require a separate prototype: searchable metadata and indexes may remain exposed and encrypted fields cannot participate in ordinary database queries. No encryption parity is claimed.

## Proposed key lifecycle

- Separate random database key per account; never derive it from email, phone number or UID.
- Keep key custody behind a platform storage interface. Android implementation must use Keystore-backed protection and be verified on Android 10+.
- Open the account database only after resolving the authenticated account and its key. Never fall back to plaintext after a key/open error.
- Inspect pending records before sign-out. Protect or synchronize them before closing the store and removing its key and local files.
- Treat clear-local-data and delete-account as separate operations. Missing keys must trigger recovery guidance, not automatic replacement that hides unsynchronized history.
- Cloud history can restore synchronized data following sign-in; local unsynchronized records need explicit recovery before key deletion.
- Browser preview continues in memory until a separate web storage/key design exists.

## Remaining validation

Integrate encrypted Drift behind the repository abstraction only after designing account-key custody and recovery. Then verify Android packaging, Keystore behavior, backup/restore and sign-out recovery. Re-benchmark the encrypted runtime on Android. Device tests remain deferred by owner direction.

ADR-001 selects Drift/SQLite for implementation. Only the isolated desktop encryption proof has passed; production health persistence is not enabled.
