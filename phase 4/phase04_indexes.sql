-- RushMore Phase 04
-- Stage 03: Index Engineering
-- Purpose: Evaluate targeted PostgreSQL index optimization.

-- Q01: Customer Order History
-- Candidate composite index for customer filtering
-- and descending order timestamp sorting.

-- First inspect existing indexes before creation.
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('orders', 'order_items')
ORDER BY tablename, indexname;

-- Candidate index (DO NOT EXECUTE YET):
-- CREATE INDEX idx_orders_customer_timestamp
-- ON orders (customer_id, order_timestamp DESC);

-- Q02: Sales Aggregation
-- No new index proposed.
-- A sequential scan may be appropriate because
-- the aggregation reads the full orders table.

-- Q03: Order Line-Item Lookup
-- Existing index: idx_order_items_order_id
-- No new index proposed until measurements
-- demonstrate a meaningful benefit.


-- RushMore Phase 04
-- Stage 03: Q01 Composite Index Experiment

CREATE INDEX IF NOT EXISTS idx_orders_customer_timestamp
ON public.orders (
    customer_id,
    order_timestamp DESC
);

-- Refresh PostgreSQL planner statistics
ANALYZE public.orders;

-- Verify the index exists
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'orders'
  AND indexname = 'idx_orders_customer_timestamp';


SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'orders'
ORDER BY indexname;


