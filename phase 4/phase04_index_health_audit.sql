SET enable_indexonlyscan = off;
SET enable_seqscan = on;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
	order_id,
	item_id,
	quantity,
	unit_price
FROM public.order_items
WHERE order_id = 100;

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'orders'
ORDER BY indexname;

SELECT
    indexname,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'orders'
  AND indexname LIKE 'idx_orders_customer_time%';

  SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('orders', 'order_items')
ORDER BY tablename, indexname;

SELECT
    t.relname AS table_name,
    i.relname AS index_name,
    pg_get_indexdef(i.oid) AS index_definition,
    x.indisvalid AS is_valid,
    x.indisready AS is_ready,
    pg_size_pretty(pg_relation_size(i.oid)) AS index_size
FROM pg_class t
JOIN pg_index x
    ON t.oid = x.indrelid
JOIN pg_class i
    ON i.oid = x.indexrelid
JOIN pg_namespace n
    ON n.oid = t.relnamespace
WHERE n.nspname = 'public'
  AND t.relname IN ('orders', 'order_items')
ORDER BY t.relname, i.relname;

SELECT
    t.relname AS table_name,
    i.relname AS index_name,
    x.indisvalid AS is_valid,
    x.indisready AS is_ready,
    pg_relation_size(i.oid) AS size_bytes
FROM pg_class t
JOIN pg_index x ON x.indrelid = t.oid
JOIN pg_class i ON i.oid = x.indexrelid
JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE n.nspname = 'public'
  AND t.relname IN ('orders', 'order_items')
ORDER BY t.relname, i.relname;