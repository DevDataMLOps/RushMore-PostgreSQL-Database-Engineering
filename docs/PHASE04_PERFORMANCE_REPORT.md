# RushMore Phase 04 — Performance and Evidence Report

**Review date:** 2026-11-02. **Documentation:** reconciled. **Engineering readiness:** conditional; reproducibility and evidence gaps remain. No database connection or SQL execution occurred during this review. No index, schema, data or database setting was changed.

This report supersedes the contradictory stage labels and unqualified performance conclusions in the [preserved prior report](PHASE04_PERFORMANCE_REPORT_PRE_20261102.md). That file is an unchanged historical record, not current sign-off. See the [audit](PHASE04_EVIDENCE_AUDIT.md) and [submission checklist](PHASE04_COMPLETION_ASSESSMENT.md).

## Evidence standard

“Inspected output” means an existing screenshot or exported result was examined; it does not mean the database was queried now. CSV measurements without a traceable original plan are recorded measurements, not independently verified outputs. Assistant transcriptions are secondary historical evidence. New user-supplied results are attributed to the user until their original artifact is retained. Correct arithmetic does not independently verify its input measurements.

## Q03 — verified index-usage observation supplied by the user

| Field | Result |
|---|---|
| Relation | public.order_items |
| Operator | Index Scan |
| Index | idx_order_items_order_id |
| Index condition | order_id = 100 |
| Actual rows | 3 |
| Index searches | 1 |
| Shared buffer hits | 3 |
| Planning time | 0.799 ms |
| Execution time | 0.049 ms |

**Source:** the user's verified result supplied for this review on 2026-11-02. Actual execution date is not supplied. No matching screenshot or complete EXPLAIN text is retained in the inspected repository; these exact numbers were not independently reverified here. A [provenance record](evidence/phase04/reconciliation/q03_user_verified_20261102.json) preserves this distinction.

**Conclusion:** this observation confirms use of the existing index for the reported lookup. It does **not** establish a comparative speedup, a five-run median, or production performance. Do not combine 0.049 ms with the historical sequential-scan series to calculate a new ratio. The older baseline run-5 screenshot shows 0.050 ms execution and 0.083 ms planning; it is a separate observation, not evidence for the new values.

## Q01 and Q02 reconciliation

| Series | Execution times (ms) | Median (ms) | Source strength |
|---|---|---:|---|
| Q01 original baseline | 0.103, 0.160, 0.074, 0.104, 0.097 | 0.103 | Five timing captures baseline-2.png through baseline-6.png inspected in the earlier audit |
| Q01 historical comparison | 0.135, 0.078, 0.079, 0.084, 0.077 | 0.079 | Transcript message 277; only runs 4–5 have retained comparison screenshots |
| Q01 separately recorded live series | 1.798, 0.075, 0.079, 0.089, 0.096 | 0.089 | q01_live_measurements.csv labels pgadmin_screenshot, but gives no per-run image path; not independently matched |
| Q02 earlier baseline | 229.273, 18.918, 18.616, 19.842, 18.773 | 18.918 | Historical report; incomplete original output |
| Q02 additional baseline | 22.333, 18.108, 19.368, 19.963, 23.188 | 19.963 | Transcript message 329; run 5 retained as baseline-q02-run5.png |
| Q02 forced-index comparison | 29.676, 24.975, 24.985, 25.687, 25.994 | 25.687 | Secondary transcript only; no comparison screenshots found |

Sources: [historical measurements](evidence/phase04/reconciliation/historical_measurements.csv), [separate Q01 series](evidence/phase04/reconciliation/q01_live_measurements.csv), [recovered transcript excerpts](evidence/phase04/recovered/chat-benchmark-records.json).

Q01's historical 23.30% median reduction and Q02's 28.67% slowdown are arithmetic on partially supported historical series, not independently verified comparative gains or penalties. Q02 message 329 establishes the intended pairing with the 19.963 ms baseline; equivalent execution conditions are not independently established. Keep the earlier 18.918 ms baseline separate. The 23.990 ms preliminary alternative-plan result is not part of the five-run comparison. The 21.004 ms capture remains unassigned. Do not discard first-run outliers or substitute the separate Q01 series into the older comparison.

Q03's historical indexed median 0.062 ms and sequential median 6.332 ms are preserved in the archived report/transcripts. Only indexed run 5 and sequential run 1 have retained timing screenshots. The former approximately 102.1x claim is not adopted as a verified conclusion in this report.

## Index health and administration

The [index-health CSV](evidence/phase04/reconciliation/index_health_20261030.csv) lists seven indexes on orders/order_items, all valid and ready, including idx_orders_customer_timestamp (958,464 bytes; customer_id, order_timestamp DESC) and idx_order_items_order_id (1,499,136 bytes). This is a retained historical catalog export, not a current database check. The [screenshot](../RushMore-Screenshots/Q04_Index_Health_Verification.png) corroborates visible rows and flags; its first row is clipped and it does not show full index definitions. The CSV's seven-index scope does not replace the older claimed 14-index inventory across six tables.

Administration SQL now includes catalog, privileges, activity and maintenance queries. Original evidence still only partially supports the historical administration narrative. The recovered admin-11 screenshot supports visible maintenance rows, not complete ongoing health. The six-table 126,085-row total remains the prior dataset record, not a new count.

## Reproducibility review — static only

| File | Current finding |
|---|---|
| phase04_baseline.sql | Normal Q01–Q03 queries plus Q03 diagnostic inside BEGIN/SET LOCAL/ROLLBACK; normal queries unqualified by schema |
| phase04_comparison.sql | Q01 and Q02 normal query plus bounded Q02 diagnostic; no Q03 block |
| phase04_forced_index_transaction.sql | BEGIN/SET LOCAL present, but no COMMIT or ROLLBACK: incomplete transaction procedure |
| phase04_forced_index_benchmark.sql | Session SET followed by RESET/SHOW; partial execution or error can bypass cleanup |
| phase04_order_items_scan_comparison.sql | Indexed and sequential diagnostic; session settings/reset without transaction scope |
| phase04_index_health_audit.sql | Catalog inspection mixed with session SET and EXPLAIN ANALYZE; not a catalog-only audit |
| phase04_indexes.sql | Contains executable CREATE INDEX IF NOT EXISTS and ANALYZE; inspection must not run the whole file |
| phase04_admin_audit.sql | Catalog audit now present, but preceded by EXPLAIN workloads and an unrelated store/date Q02 |

All scripts remain unchanged. Do not execute them as a batch for evidence review. Presence of rollback/reset text does not prove actual session cleanup. No PostgreSQL parser, runtime validation, or repeatability test was performed. The previously prepared replacement SQL under the chat's outputs was not applied over the user's newer scripts.

## Completion assessment

Documentation now distinguishes retained output, transcription and user-confirmed observations. Index use is supported; unqualified comparative-speedup claims are withheld. Phase 04 documentation is finalized with disclosed limitations, but unconditional engineering sign-off and final submission readiness are **not established**. Resolve the prioritized checklist before claiming reproducibility or submitting missing evidence as complete.
