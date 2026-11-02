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