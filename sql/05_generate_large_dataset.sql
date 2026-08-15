INSERT INTO customers (
    first_name,
	last_name,
	email,
	city,
	registration_date
)
SELECT
    'Customer_' || g AS first_name,
	'Surname_' || g AS last_name,
	'customer' || g || '@gmail.com' AS email,

	CASE
	   WHEN g % 20 = 0 THEN 'Warszawa'
	   WHEN g % 20 = 1 THEN 'Lodz'
	   WHEN g % 20 = 2 THEN 'Krakow'
	   WHEN g % 20 = 3 THEN 'Wroclaw'
	   WHEN g % 20 = 4 THEN 'Poznan'
	   WHEN g % 20 = 5 THEN 'Gdansk'
	   WHEN g % 20 = 6 THEN 'Szczecin'
	   WHEN g % 20 = 7 THEN 'Lublin'
	   WHEN g % 20 = 8 THEN 'Bialystok'
	   WHEN g % 20 = 9 THEN 'Katowice'
	   WHEN g % 20 = 10 THEN 'Gdynia'
	   WHEN g % 20 = 11 THEN 'Torun'
	   WHEN g % 20 = 12 THEN 'Bydgoszcz'
	   WHEN g % 20 = 13 THEN 'Rzeszow'
	   WHEN g % 20 = 14 THEN 'Olsztyn'
	   WHEN g % 20 = 15 THEN 'Opole'
	   WHEN g % 20 = 16 THEN 'Gliwice'
	   WHEN g % 20 = 17 THEN 'Radom'
	   WHEN g % 20 = 18 THEN 'Kielce'
	   ELSE 'Zielona Gora'
   END AS city,

   DATE '2024-01-01'
        +  ((g * 7) % 700)::INTEGER
		AS registration_date

FROM generate_series(21, 500) AS g

ON CONFLICT (email) DO NOTHING;

SELECT COUNT(*) AS customers_count
FROM customers;

SELECT
    category_id,
	category_name
FROM categories
ORDER BY category_id;

INSERT INTO products (
    product_name,
	category_id,
	unit_price,
	cost_price
)

SELECT
    'Product_' || g AS product_name,

	(
        SELECT c.category_id
		FROM categories AS c
		ORDER BY c.category_id
		OFFSET ((g - 1) % (SELECT COUNT(*) FROM categories))
		LIMIT 1
	) AS category_id,
	
	ROUND(
       (100 + ((g * 37) % 4900))::NUMERIC,
	   2
	) AS unit_price,

	ROUND(
        (
            (100 + ((g * 37) % 4900))
			* (0.65 + ((g % 20) / 100.0))
		)::NUMERIC,
		2
	) AS cost_price

FROM generate_series(25, 200) AS g;

SELECT COUNT(*) AS products_count
FROM products;

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
	    + (g.order_number * 20 + c.customer_id % 25)::INTEGER
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

CROSS JOIN generate_series(1, 5) AS g(order_number)

WHERE c.customer_id > 20;

SELECT COUNT(*) AS orders_count
FROM orders;

SELECT 
    order_status,
	COUNT(*) AS orders_count
FROM orders
GROUP BY order_status
ORDER BY orders_count DESC;

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
        o.order_id::TEXT
		|| '-'
		|| p.product_id::TEXT
	)

	LIMIT 1 + (o.order_id) % 5
) AS selected_products

WHERE o.order_id > 60;

SELECT COUNT(*) AS order_items_count
FROM order_items;

SELECT
    ROUND(
        COUNT(*)::NUMERIC / COUNT(DISTINCT order_id),
		2
	) AS average_items_per_order
FROM order_items;

SELECT
    (SELECT COUNT(*) FROM customers) AS customers_count,
	(SELECT COUNT(*) FROM categories) AS categories_count,
	(SELECT COUNT(*) FROM products) AS products_count,
	(SELECT COUNT(*) FROM orders) AS orders_count,
	(SELECT COUNT(*) FROM order_items) AS order_items_count;


	   