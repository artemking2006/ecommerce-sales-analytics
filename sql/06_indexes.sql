EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 250;

CREATE INDEX
idx_orders_customer_id
ON orders(customer_id)

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 250;

CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category_id ON products(category_id);

SELECT
    tablename,
	indexname,
	indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE order_date BETWEEN DATE
'2025-06-01'
                     AND DATE
'2025-06-30';