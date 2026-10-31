# Phase 04 evidence audit — 2026-10-30

**Closure decision: BLOCKED.** This is a repository and retained-image audit, not a new database execution. The report's historical measurements are preserved; unsupported claims remain unverified. No SQL, benchmark, database object, commit, or push was executed by this audit.

## Reconciled evidence inventory

All 19 PNG files in `docs/evidence/phase04` were opened and visually inspected. File count is not execution count; multiple captures can represent one execution, and one retained capture cannot establish five executions.

| Workload | Retained evidence | Supported observation | Gap |
|---|---|---|---|
| Q01 baseline | `baseline-1.png` through `baseline-6.png` (6 captures) | `baseline-2` through `baseline-6` match the five report rows: execution 0.103, 0.160, 0.074, 0.104, 0.097 ms; planning 0.339, 0.181, 0.108, 0.110, 0.138 ms. `baseline-1` is an additional upper-plan view, not a sixth measured run. | No missing timing row in the documented baseline series. Run mapping is by displayed timings, not filenames alone. |
| Q01 comparison | `comparison-q01-run4.png`, `comparison-q01-run5.png` | Execution 0.084 / 0.077 ms; planning 0.123 / 0.120 ms. Both show Bitmap Index Scan on `idx_orders_customer_timestamp`. | Runs 1–3 and full five-run timing table absent. Median 0.079 ms cannot be independently reconstructed. Upper plan/sort not visible in these captures. |
| Q02 baseline | `baseline-sql-3.png`, `baseline-sql-5.png`, `baseline-q02-run5.png` (3 captures) | Execution/planning: 21.004/0.148, 18.616/0.120, 23.188/0.118 ms. All show sequential scan and 221 shared hits. | 21.004 belongs to neither documented series; do not assign a run number. 18.616 matches earlier series run 3; 23.188 matches additional series run 5. Matching timing alone does not establish provenance. |
| Q02 comparison | None | No retained forced-index plan or timing verified. | All five referenced `comparison-q02-run1.png` through `comparison-q02-run5.png` absent; raw five-run timing table absent. |
| Q03 baseline | `baseline-q03-run5.png` | Execution 0.050 ms, planning 0.083 ms, Index Scan on `idx_order_items_order_id`, 3 hits, 3 rows. | Runs 1–4 lack retained source output. `admin-2.png` is another partial Q03 indexed plan, not a timed baseline run. |
| Q03 comparison | `comparison-q03-run1.png` | Execution 6.345 ms, planning 0.205 ms; sequential scan, 89,997 rows removed, 3 returned, 574 hits. | Runs 2–5 absent. Visible SQL uses ordinary `SET`, unlike current script's `SET LOCAL`; historical cleanup is unverified. |
| Q01 catalog verification | Expected `q01-composite-index-verification.png` absent | Comparison captures prove historical use of an index with that name. | No current catalog definition, validity/readiness, size, or timestamped verification. Absence of the file does not establish absence of the index. |

## References and administration evidence

The original report's Q02 list names five missing comparison files. Its Q03 range implies five files but only run 1 exists; `docs/evidence/...` is also the wrong report-relative prefix. These claims are replaced by an explicit missing-evidence statement and an existing run-1 link.

The six administration captions were inaccurate. Actual contents: `admin-1` VS Code setup; `admin-2` partial Q03 plan; `admin-3` database identity/version (18.6); `admin-4` size (22 MB); `admin-5` table storage/estimated rows; `admin-6` role flags. The corrected captions do not prove the original connection-statistics, transaction/cache, 14-index inventory, maintenance, or database CONNECT/CREATE/TEMP privilege claims. Recover their original output or mark those claims unverified. The present admin SQL contains workload queries, not the administration queries shown in images.

## Arithmetic versus measurement verification

Recalculation from the report's listed rows gives:

| Series | Median execution ms | Mean execution ms | Audit interpretation |
|---|---:|---:|---|
| Q01 baseline | 0.103 | 0.1076 → 0.108 | Five displayed timings agree with report. Planning median 0.138; mean 0.1752 → 0.175. |
| Q02 earlier baseline | 18.918 | 61.0844 | Median arithmetic correct; incomplete source support. Keep the 229.273 first run, without silently discarding it. |
| Q02 additional baseline | 19.963 | 20.592 | Arithmetic correct; only run 5 directly matched in retained evidence. Planning median 0.118; mean 0.137. |
| Q03 indexed baseline | 0.062 | 0.288 | Arithmetic correct; only run 5 matched. |
| Q03 sequential comparison | 6.332 | 7.6042 → 7.604 | Arithmetic correct; only run 1 matched. |

From reported medians, Q01 reduction is 23.30097% and speedup 1.30380; Q02 difference is 5.724 ms and slowdown 28.67305%; Q03 ratio is 102.12903. These calculations are correct but do not validate missing inputs. Do not recalculate a five-run median from two retained Q01 screenshots or mix Q02 series. The 18.773 ms earlier Q02 run-5 claim is not supported by the named run-5 image (23.188 ms). Q03's quoted 0.032–0.057 ms range is not its documented five-run baseline range (0.047–1.214 ms); retain it only with a separate source.

## SQL and transaction audit

1. `phase04_baseline.sql` has the three normal workloads followed by one Q03 diagnostic inside `BEGIN; ... SET LOCAL ... EXPLAIN ... ROLLBACK;`. The local settings are bounded when the entire block executes. The file does not implement five repetitions automatically.
2. Transaction end restores the session values that existed beforehand, not necessarily defaults. The screenshot's ordinary `SET enable_indexonlyscan = off` and `SET enable_seqscan = on` cannot be treated as proof of scoped execution or cleanup. Record settings before/after; execute the complete diagnostic transaction in a dedicated session with no unrelated open transaction. A selected EXPLAIN alone does not execute preceding settings.
3. `phase04_comparison.sql` contains only Q01. Q02's `SET LOCAL enable_seqscan = off` experiment is absent. Q03 is misplaced in baseline. Prepare separate, labeled Q02/Q03 comparison transactions and use `public` qualification consistently. Confirm actual access paths from output rather than assuming planner flags guarantee them.
4. `phase04_admin_audit.sql` is mislabeled baseline SQL, with a different Q02 (store/date filter) from the documented customer aggregation. Recover the administration queries actually used; do not associate that Q02 with the aggregation measurements.
5. `phase04_indexes.sql` inspects index names/definitions, but its CREATE INDEX is commented out. It does not prove deployment, current validity, size, or the full inventory. No DDL is needed for this audit.

SET LOCAL scope is documented in [PostgreSQL SET documentation](https://www.postgresql.org/docs/18/sql-set.html). No live settings or database state were inspected.

## Remediation plan and acceptance criteria

1. **Documentation review now:** review the accompanying diff, corrected image captions, explicit missing references, and audit notice. Preserve original timings and historical sections. The audit notice takes precedence over historical completed/pending labels; they are not current sign-off statuses.
2. **Recover historical sources:** obtain original Q01 comparison runs 1–3 plus all five values, Q02 forced-index runs 1–5 plus values, missing Q02 baseline sources/provenance, Q03 baseline runs 1–4 and sequential runs 2–5. Text EXPLAIN output or contemporaneous logs are acceptable; five screenshot files are not mandatory. Add a manifest with query, series, run, timing, plan, settings, dataset/index state, capture date, and source. Do not rename unrelated captures to fill gaps.
3. **Reconcile Q02:** keep earlier 18.918 and additional 19.963 series distinct; identify which controlled series pairs with the 25.687 comparison. Assign 21.004 only when provenance is recovered. Until then, comparison conclusions remain provisional.
4. **Catalog verification:** in an approved read-only session, capture database identity and the Q01 index definition on `public.orders`, including keys/order, `pg_index.indisvalid`, `indisready`, and index size. Reconcile the claimed 14-index baseline with a dated inventory. Capture actual results; do not create/drop indexes to satisfy the report.
5. **Reproducibility review:** restore admin SQL; prepare Q02 and Q03 diagnostic blocks in comparison SQL; preserve the normal baseline workloads. Record session settings before/after and execute whole blocks. Review SQL changes separately before any database execution.
6. **Only if recovery fails:** request approval for a new benchmark series in a suitable environment. New measurements must have new series IDs and must not be represented as the missing historical runs. Never drop a live index to reconstruct an old baseline without separate authorization.
7. **Closure:** all claimed medians trace to five source measurements, all referenced artifacts exist and match captions, workload/index/settings provenance is recorded, SQL procedures match the experiments, and Git diff is reviewed. Commit/push remains a separate user decision.

See `git-audit.json` in the review deliverables for HEAD, cached upstream comparison, staged diff, and fallback working-file comparison. The normal git-status command failed under this execution environment; do not claim a fully verified clean working tree from prior-chat screenshots. No remote freshness is asserted without fetch.

## Original-evidence recovery follow-up

Partial recovery added an original maintenance screenshot and 20 local pgAdmin history records. See [the recovery report](PHASE04_RECOVERY_REPORT.md) and its [source manifest](evidence/phase04/recovered/manifest.json). The history records SQL submissions, a RESET followed by later setting changes, and a successful catalog query; it does not retain result rows or PostgreSQL execution times. The original missing benchmark outputs and catalog-definition evidence remain unresolved. Closure remains **BLOCKED**.
