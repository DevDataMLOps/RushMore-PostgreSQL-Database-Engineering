# Phase 04 original-evidence recovery

**Result: partial recovery; final closure remains BLOCKED.** No benchmarks, PostgreSQL queries, DDL, commits, or pushes were performed.

## Recovered

- **Original maintenance screenshot:** `admin-11.png`, copied byte-for-byte from OneDrive's `Videos/Pictures/Screenshots/phase 4 evidence` folder. It shows a six-row maintenance result; five table rows are visible with zero estimated dead tuples and some autovacuum timestamps. The sixth row and right-hand columns are clipped. This supports part of the maintenance narrative, not every maintenance claim or a current health assessment.
- **20 original local pgAdmin history entries:** exported read-only from `query_history` for `rushmore_db` into `pgadmin-rushmore-history.json`. Original SQL, UTC timestamps, success/failure flags, affected-row metadata, and client runtimes are retained. No server credentials or other databases were exported. This is a structured extraction, not a screenshot or original EXPLAIN result.
- History includes successful Q03 diagnostic submissions, a successful four-setting RESET at `2026-10-30T04:10:34.156Z` (00:10:34 EDT), and later submissions that changed the settings again. RESET therefore does not establish the final session settings. The history has no backend/session identifier sufficient to prove one uninterrupted connection.
- The index-definition query ending in `indexname LIKE 'idx_orders_customer_time%'` is recorded successful at `2026-10-30T23:18:36.781Z` (19:18:36 EDT), with one row affected. Its returned index name/definition is not retained, so it does not replace the missing catalog result or validity/size evidence. Earlier attempts failed on a nonexistent `indexrelid` column.

## Duplicates and searches

- `comparison-sql-4.png` and `comparison-sql-5.png` in the repository's parent directory are byte-identical to the already-retained Q01 comparison runs 4 and 5. They add no runs.
- Inspected the OneDrive screenshot folder and its Phase 04/Q01 subfolders, Downloads/RushMore-Screenshots, repository parent, and candidate filenames under Downloads, OneDrive, and Pictures. Six generic recent screenshots show VS Code audit/commit work, not missing benchmark output.
- Reachable Git evidence history contains the same retained PNGs and Q01 baseline directory renames; no missing run images were recovered from it. An unreachable commit contains an earlier Q02 report plus the already-retained baseline image, not additional original result images. Git inventory is preserved with this report.
- VS Code local history contains 21 report versions and 9 SQL versions. The stored admin script still contains workload SQL; the comparison script is Q01-only. Report versions are secondary documentation, not independent proof of original measurements. Their paths, versions, timestamps and hashes are recorded.
- The RushMore starter ZIP contains no Phase 04 evidence. The pgAdmin storage directory and Snipping Tool package search yielded no PNG/JPG candidates or saved result exports. No cloud-only recovery, recycle-bin restore, or account-wide attachment search was performed.

## Remaining gaps

| Gap | Recovery outcome |
|---|---|
| Q01 comparison runs 1–3 and complete five-run timing table | Not found in inspected sources. |
| Q02 forced-index runs 1–5 and raw timing table | Not found. |
| Q02 baseline-series provenance, including unexplained 21.004 ms capture | Unresolved; keep 18.918 and 19.963 ms series separate. |
| Q03 baseline runs 1–4 and comparison runs 2–5 | SQL submission history recovered, but original plan/timing outputs not found. Do not map history entries to reported run numbers without independent evidence. |
| Q01 catalog definition/validity/readiness/size | Successful query history found; returned catalog rows still missing. |
| Administration audit | Partial maintenance screenshot recovered; other missing administration results and executable audit procedure remain unresolved. |

**Critical distinction:** pgAdmin `total_time` is client runtime. Values such as 747 ms must not replace PostgreSQL EXPLAIN `Execution Time` values such as 6.345 ms. Multiple SQL statements in a history entry also prevent assuming one entry equals one benchmark run.

## Next recovery source

If the original benchmark screenshots were attached to an earlier chat, those original attachments or a chat export are the next useful source. The currently referenced chat preview supplies only late audit/commit screenshots. An older benchmark chat link or the original exports can close gaps without rerunning. Also consider a known backup of the screenshot folder if one exists. Do not relabel newly captured results as historical evidence.

Manifest checksums identify the preserved files. No phase sign-off status has been upgraded.
