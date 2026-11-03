# Encrypted Drift proof

Isolated desktop-only prototype for Sehat Coach V1-M02. It uses the sqlite3mc native-assets hook and synthetic data. It is not wired into the app or production account data.

Run from this directory:

```powershell
dart pub get
dart analyze
dart run run.dart
```

The script creates a random key in memory, writes a synthetic record, confirms correct-key reopen and wrong/missing-key rejection, checks an additive migration and transaction rollback, then leaves the synthetic database in the OS temporary directory. It never prints the key. Delete the scratch directory manually when no longer needed.

Passing here does not validate Android 10+ native packaging, Keystore-backed key custody, backup/restore, sign-out, or sync recovery.
