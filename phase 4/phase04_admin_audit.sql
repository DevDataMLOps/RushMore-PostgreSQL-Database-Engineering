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

