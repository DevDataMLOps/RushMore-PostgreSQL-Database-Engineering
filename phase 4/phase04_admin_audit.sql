-- RushMore Phase 04
-- Stage 02: Baseline Performance
-- Run each query 3-5 times under similar conditions.
-- Record execution time, buffer usage, and plan type.

-- Q01: Customer order history
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_timestamp, total_amount
FROM orders
WHERE customer_id = 100
ORDER BY order_timestamp DESC
LIMIT 20;

-- Q02: Store sales within a date range
EXPLAIN (ANALYZE, BUFFERS)
SELECT store_id, COUNT(*) AS order_count,
       SUM(total_amount) AS revenue
FROM orders
WHERE store_id = 1
  AND order_timestamp >= DATE '2026-01-01'
  AND order_timestamp < DATE '2027-01-01'
GROUP BY store_id;

-- Q03: Order line-item lookup
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, item_id, quantity, unit_price
FROM order_items
WHERE order_id = 100;

SELECT
    current_database() AS database_name,
    current_user AS connected_user,
    version() AS postgresql_version,
    current_setting('server_version') AS server_version;

SELECT
    current_database() AS database_name,
    pg_size_pretty(
        pg_database_size(current_database())
    ) AS database_size;

-- RushMore Phase 04
-- Stage 01: Table Storage Audit

SELECT
    relname AS table_name,
    n_live_tup AS estimated_rows,
    pg_size_pretty(
        pg_relation_size(relid)
    ) AS table_data_size,
    pg_size_pretty(
        pg_indexes_size(relid)
    ) AS index_size,
    pg_size_pretty(
        pg_total_relation_size(relid)
    ) AS total_size
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(relid) DESC;

-- RushMore Phase 04
-- Stage 01: Database Roles Audit

SELECT
    rolname AS role_name,
    rolcanlogin AS can_login,
    rolsuper AS is_superuser,
    rolcreatedb AS can_create_database,
    rolcreaterole AS can_create_role,
    rolreplication AS can_replicate
FROM pg_roles
WHERE rolname = current_user
   OR rolname = 'rushmore_admin'
ORDER BY rolname;

-- RushMore Phase 04
-- Stage 01: Database Privilege Audit

SELECT
    current_user AS role_name,
    current_database() AS database_name,
    has_database_privilege(
        current_user,
        current_database(),
        'CONNECT'
    ) AS can_connect,
    has_database_privilege(
        current_user,
        current_database(),
        'CREATE'
    ) AS can_create,
    has_database_privilege(
        current_user,
        current_database(),
        'TEMP'
    ) AS can_create_temp;

-- RushMore Phase 04
-- Stage 01: PostgreSQL Connection Activity Audit

SELECT
    datname AS database_name,
    state AS connection_state,
    COUNT(*) AS connection_count
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY datname, state
ORDER BY connection_count DESC;

-- RushMore Phase 04
-- Stage 01: Database Connection Statistics

SELECT
    datname AS database_name,
    numbackends AS current_connections,
    xact_commit AS committed_transactions,
    xact_rollback AS rolled_back_transactions,
    blks_read AS disk_blocks_read,
    blks_hit AS cache_blocks_hit,
    ROUND(
        100.0 * blks_hit /
        NULLIF(blks_hit + blks_read, 0),
        2
    ) AS cache_hit_percentage
FROM pg_stat_database
WHERE datname = current_database();

-- RushMore Phase 04
-- Stage 01: Existing Index Inventory

SELECT
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
      'stores',
      'customers',
      'ingredients',
      'menu_items',
      'orders',
      'order_items'
  )
ORDER BY tablename, indexname;

-- RushMore Phase 04
-- Stage 01: Table Maintenance Audit

SELECT
    relname AS table_name,
    n_live_tup AS estimated_live_rows,
    n_dead_tup AS estimated_dead_rows,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY relname;