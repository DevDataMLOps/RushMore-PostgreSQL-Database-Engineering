EXPLAIN (ANALYZE, BUFFERS)
SELECT
    order_id,
    item_id,
    quantity,
    unit_price
FROM public.order_items
WHERE order_id = 100;

SET enable_indexscan = off;
SET enable_bitmapscan = off;
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

RESET enable_indexscan;
RESET enable_bitmapscan;
RESET enable_indexonlyscan;
RESET enable_seqscan;