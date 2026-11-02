-- RushMore Phase 03
-- Final Transaction Integrity Validation

SELECT
    'invalid_order_quantities' AS check_name,
    COUNT(*) AS violations
FROM order_items
WHERE quantity IS NULL OR quantity <= 0

UNION ALL

SELECT
    'invalid_unit_prices',
    COUNT(*)
FROM order_items
WHERE unit_price IS NULL OR unit_price < 0

UNION ALL

SELECT
    'invalid_order_totals',
    COUNT(*)
FROM orders
WHERE total_amount IS NULL OR total_amount < 0

UNION ALL

SELECT
    'orders_without_items',
    COUNT(*)
FROM orders o
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.order_id = o.order_id
)

UNION ALL

SELECT
    'order_total_mismatches',
    COUNT(*)
FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS calculated_total
    FROM order_items
    GROUP BY order_id
) oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NOT NULL
  AND ABS(
      o.total_amount - oi.calculated_total
  ) > 0.01;
