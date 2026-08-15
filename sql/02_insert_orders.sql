SELECT
    customer_id,
	first_name,
	last_name,
	city,
	registration_date
FROM customers
ORDER BY customer_id;

INSERT INTO orders (
    customer_id,
	order_date,
	order_status,
	payment_method,
	shipping_city
)
SELECT
    c.customer_id,

	c.registration_date
	    + (g.order_number * 14 + c.customer_id % 10)::INTEGER
		AS order_date,

		CASE
		    WHEN (c.customer_id + g.order_number) % 10 IN (0, 1)
			    THEN 'Cancelled'
			WHEN (c.customer_id + g.order_number) % 10 = 2
			    THEN 'Pending'
			ELSE 'Completed'
		END AS order_status,

	    CASE
		   WHEN (c.customer_id + g.order_number) % 4 = 0
		       THEN 'Card'
		   WHEN (c.customer_id + g.order_number) % 4 = 1
		       THEN 'BLIK'
		   WHEN (c.customer_id + g.order_number) % 4 = 2
		       THEN 'Bank Transfer'
		   ELSE 'Cash on Delivery'
		END AS payment_method,

		c.city AS shipping_city

FROM customers AS c
CROSS JOIN generate_series(1, 3) AS g(order_number);

INSERT INTO order_items (
    order_id,
	product_id,
	quantity,
	unit_price,
	discount_percent
)
SELECT
    o.order_id,
	selected_products.product_id,

	1 + ((o.order_id + selected_products.product_id) % 3)::INTEGER
	    AS quantity,

	selected_products.unit_price,

	CASE
	   WHEN (o.order_id + selected_products.product_id) % 10 = 0
	       THEN 20.00
	   WHEN (o.order_id + selected_products.product_id) % 7 = 0
	       THEN 10.00
	   WHEN (o.order_id + selected_products.product_id) % 5 = 0
	       THEN 5.00
	   ELSE 0.00
	END AS discount_percent

FROM orders AS o

CROSS JOIN LATERAL (
    SELECT
	    p.product_id,
		p.unit_price
	FROM products AS p
	ORDER BY MD5(
        o.order_id::TEXT || '-' || p.product_id::TEXT)
	LIMIT 1 + (o.order_id % 4)
	) AS selected_products;

SELECT COUNT(*) AS orders_count
FROM orders;

SELECT COUNT(*) AS order_items_count
FROM order_items;

	




