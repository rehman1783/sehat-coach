# Desktop development comparison — 21 October 2026

Windows x64, Intel Core i7-10610U, Dart 3.13.5 JIT. Drift 2.31.0, sqlite3 Dart package 2.9.4, ObjectBox Dart/native 5.3.2. Five fresh-store runs per candidate, 10,000 synthetic foods, 2,000 meals. Raw timings are in `results-windows-2026-10-21.jsonl`.

| Metric | Drift/SQLite | ObjectBox |
|---|---:|---:|
| Median import | 53.292 ms | 196.765 ms |
| Median prefix search | 1.352 ms | 0.864 ms |
| Prefix search p95 | 2.681 ms | 1.815 ms |
| Median meal total | 0.528 ms | 23.543 ms |

All correctness checks passed. Search statistics pool 300 observations per candidate, including the empty-result prefix. Percentiles use nearest rank; the even sample median shown uses the lower middle observation. Drift runs first in each pair; JIT warmup, OS caching and ordering can bias results. These are development timings, not release benchmarks.

Drift uses a SQL join and SUM; ObjectBox traverses ToOne relations in Dart. The aggregation difference measures those implementations, not an intrinsic database limit. Schema setup is included in Drift import timing; ObjectBox store setup occurs before the import timer. A final report must measure startup separately and normalize setup boundaries.

Native runtime was downloaded from the official ObjectBox C v5.3.2 Windows x64 release into ignored `.cache/objectbox-runtime`. Add its `extracted/lib` directory to PATH for this process, then run `dart run run.dart` in this package. No system-wide runtime installation was performed. Temporary benchmark stores were retained for diagnosis.

Selection outcome: ADR-001 selects Drift/SQLite for implementation. Subsequent isolated checks completed migration/rollback, basic reactive queries, outbox/conflict transactions and a desktop encrypted Drift proof. Android encrypted performance and key custody remain integration/release gates and stay deferred by owner direction; these Windows results must not be presented as Android performance evidence.
