-- RushMore Phase 04
-- Stage 04: Post-Optimization Benchmark
-- Q01: Customer Order History
-- Execute five times and record execution time.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    customer_id,
    order_timestamp,
    total_amount
FROM public.orders
WHERE customer_id = 100
ORDER BY order_timestamp DESC
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales
FROM public.orders
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 20;


-- RushMore Phase 04
-- Stage 03: Q02 Index Evaluation
-- Test existing index-access alternatives
-- No permanent database changes

BEGIN;

SET LOCAL enable_seqscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales
FROM public.orders
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 20;

ROLLBACK;
