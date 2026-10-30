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
