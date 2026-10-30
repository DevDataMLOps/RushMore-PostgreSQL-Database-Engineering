-- Q01: Customer Order History
-- Capture baseline before creating new indexes

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    order_timestamp,
    total_amount
FROM orders
WHERE customer_id = 100
ORDER BY order_timestamp DESC
LIMIT 20;

-- Q02: Sales Aggregation
-- Pre-optimization baseline
-- Execute five times and record execution times.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 20;

-- Q03: Order Line-Item Lookup
-- Stage 02: Pre-Optimization Baseline
-- Execute five times before creating new indexes.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    item_id,
    quantity,
    unit_price
FROM order_items
WHERE order_id = 100;

BEGIN;

SET LOCAL enable_indexscan = off;
SET LOCAL enable_bitmapscan = off;
SET LOCAL enable_indexonlyscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    item_id,
    quantity,
    unit_price
FROM public.order_items
WHERE order_id = 100;

ROLLBACK;

