SELECT
    (SELECT COUNT(*) FROM customers)  AS customers_count,
	(SELECT COUNT(*) FROM categories) AS categories_count,
	(SELECT COUNT(*) FROM products)   AS products_count,
	(SELECT COUNT(*) FROM orders) AS o_count,
	(SELECT COUNT(*) FROM order_items) AS order_items_count;

SELECT
    ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		)
		/ COUNT(DISTINCT o.order_id),
		2
	) AS average_order_value

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products as p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed';

SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders
	FROM orders AS o
	WHERE o.order_status = 'Completed';

SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_revenue,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_percent / 100)
                - p.cost_price
            )
        ),
        2
    ) AS total_profit,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_percent / 100)
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed';

SELECT 
    c.category_name,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
	) AS revenue,

	ROUND(
         SUM(
             oi.quantity
			 * (
                 oi.unit_price
				 * (1 - oi.discount_percent / 100)
				 - p.cost_price
			)
		),
		2
	) AS profit,

	SUM(oi.quantity) AS units_sold

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
JOIN categories AS c
    ON p.category_id = c.category_id

WHERE o.order_status = 'Completed'

GROUP BY c.category_name

ORDER BY revenue DESC;

SELECT
    p.product_name,
	c.category_name,

	SUM(oi.quantity) AS units_sold,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
	) AS revenue

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
JOIN categories AS c
    ON p.category_id = c.category_id

WHERE o.order_status = 'Completed'

GROUP BY 
    p.product_id,
	p.product_name,
	c.category_name

ORDER BY revenue DESC

LIMIT 10;

SELECT
    p.product_name,
    c.category_name,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_percent / 100)
                - p.cost_price
            )
        ),
        2
    ) AS profit

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
JOIN categories AS c
    ON p.category_id = c.category_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name,
    c.category_name

ORDER BY profit DESC

LIMIT 10;

SELECT 
    o.shipping_city,

	COUNT(DISTINCT o.order_id) AS completed_orders,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
    ) AS revenue,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		)
		/ COUNT(DISTINCT o.order_id),
		2
	) AS average_order_value

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY o.shipping_city

ORDER BY revenue DESC;

SELECT 
    order_status,
	COUNT(*) AS number_of_orders,

	ROUND(
        COUNT(*) * 100.0
		/ SUM(COUNT(*)) OVER (),
		2
	) AS percentage

FROM orders

GROUP BY order_status

ORDER BY number_of_orders DESC;

SELECT 
    c.customer_id,
	c.first_name,
	c.last_name,
	c.city,

	COUNT(DISTINCT o.order_id) AS completed_orders,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
	) AS total_spent

FROM customers AS c

JOIN orders AS o
    ON c.customer_id = o.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY 
    c.customer_id,
	c.first_name,
	c.last_name,
	c.city

ORDER BY total_spent DESC

LIMIT 10;

SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS sales_month,

	COUNT(DISTINCT o.order_id) AS completed_orders,

	SUM(oi.quantity) AS units_sold,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
	) AS revenue,

	ROUND(
        SUM(
            oi.quantity
			* (
                oi.unit_price
				* (1 - oi.discount_percent / 100)
				- p.cost_price
			)
		),
		2
	) AS profit

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON  oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY DATE_TRUNC('month', o.order_date)

ORDER BY sales_month;

SELECT 
    c.customer_id,
	c.first_name,
	c.last_name,
	c.city,

	COUNT(DISTINCT o.order_id) AS completed_orders,

	ROUND(
        SUM(
            oi.quantity
			* (
               oi.unit_price
			   * (1 - oi.discount_percent / 100)
			   - p.cost_price
			)
		 ),
		 2
	) AS total_profit

FROM customers AS c

JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    c.customer_id,
	c.first_name,
	c.last_name,
	c.city

ORDER BY total_profit DESC

LIMIT 10;

SELECT 
    o.payment_method,

	COUNT(DISTINCT o.order_id) AS completed_orders,

	SUM(oi.quantity) AS units_sold,

	ROUND(
        SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
	) AS revenue,

	ROUND(
        SUM(
           oi.quantity
		   * (
              oi.unit_price
			  * (1 - oi.discount_percent / 100)
			  - p.cost_price
		   )
	    ),
		2
	) AS profit

FROM orders AS o

JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY 
    o.payment_method

ORDER BY
    revenue DESC;

SELECT
    oi.discount_percent,

    COUNT(DISTINCT o.order_id) AS orders_count,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS revenue,

    ROUND(
        AVG(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS average_line_value

FROM orders AS o

JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    oi.discount_percent

ORDER BY
    oi.discount_percent;

	SELECT
    oi.discount_percent,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
        ),
        2
    ) AS revenue_without_discount,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS revenue_after_discount,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * oi.discount_percent / 100
        ),
        2
    ) AS discount_amount

FROM orders AS o

JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    oi.discount_percent

ORDER BY
    oi.discount_percent;
	