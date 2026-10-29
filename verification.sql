-- RushMore Phase 03 verification. Run after Python loader reports COMMITTED.
SELECT 'stores' AS table_name, count(*) AS row_count FROM stores
UNION ALL SELECT 'customers', count(*) FROM customers
UNION ALL SELECT 'ingredients', count(*) FROM ingredients
UNION ALL SELECT 'menu_items', count(*) FROM menu_items
UNION ALL SELECT 'orders', count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items
ORDER BY table_name;

-- Expected zero for each failing-record count.
SELECT 'orphan_orders_customer' AS test, count(*) AS failures FROM orders o LEFT JOIN customers c ON c.customer_id=o.customer_id WHERE o.customer_id IS NOT NULL AND c.customer_id IS NULL
UNION ALL SELECT 'orphan_orders_store', count(*) FROM orders o LEFT JOIN stores s ON s.store_id=o.store_id WHERE s.store_id IS NULL
UNION ALL SELECT 'orphan_items_order', count(*) FROM order_items oi LEFT JOIN orders o ON o.order_id=oi.order_id WHERE o.order_id IS NULL
UNION ALL SELECT 'orphan_items_menu', count(*) FROM order_items oi LEFT JOIN menu_items m ON m.item_id=oi.item_id WHERE m.item_id IS NULL
UNION ALL SELECT 'invalid_quantity_or_price', count(*) FROM order_items WHERE quantity <= 0 OR unit_price < 0
UNION ALL SELECT 'negative_stock', count(*) FROM ingredients WHERE stock_quantity < 0
UNION ALL SELECT 'duplicate_customer_email', count(*) FROM (SELECT email FROM customers GROUP BY email HAVING count(*) > 1) d
UNION ALL SELECT 'duplicate_customer_phone', count(*) FROM (SELECT phone_number FROM customers GROUP BY phone_number HAVING count(*) > 1) d
UNION ALL SELECT 'orders_without_items', count(*) FROM orders o WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id=o.order_id)
UNION ALL SELECT 'order_total_mismatch', count(*) FROM orders o JOIN (SELECT order_id, sum(quantity * unit_price) AS calculated_total FROM order_items GROUP BY order_id) oi ON oi.order_id=o.order_id WHERE o.total_amount <> oi.calculated_total
ORDER BY test;

-- Should be 30000 orders, 90000 line items, average 3.0 lines per order.
SELECT count(DISTINCT order_id) AS orders_with_items, count(*) AS item_rows,
       round(count(*)::numeric / NULLIF(count(DISTINCT order_id),0),2) AS avg_items_per_order
FROM order_items;

-- Performance evidence: capture actual query plan from pgAdmin Messages / Data Output.
EXPLAIN (ANALYZE, BUFFERS)
SELECT store_id, date_trunc('month', order_timestamp) AS month, count(*) AS orders_count,
       sum(total_amount) AS revenue
FROM orders
GROUP BY store_id, date_trunc('month', order_timestamp)
ORDER BY month DESC, store_id;
