CREATE OR REPLACE VIEW vw_sales_details AS
SELECT
    o.order_id,
	o.order_date,
	o.order_status,
	o.payment_method,
	o.shipping_city,

	c.customer_id,
	c.first_name,
	c.last_name,

	oi.order_item_id,
	p.product_id,
	p.product_name,
	cat.category_name,

	oi.quantity,
    oi.unit_price,
	p.cost_price,
	oi.discount_percent,

	ROUND(
       oi.quantity * oi.unit_price,
	   2
	) AS gross_amount,

	ROUND(
       oi.quantity
	   * oi.unit_price
	   * (1 - oi.discount_percent / 100),
	   2
	) AS net_amount,

	ROUND(
       oi.quantity
	   * (
           oi.unit_price
		   * (1 - oi.discount_percent / 100)
		   - p.cost_price
	   ),
	   2
	) AS profit


	FROM orders AS o

	JOIN customers AS c
	    ON o.customer_id = c.customer_id
	JOIN order_items AS oi
	    ON o.order_id = oi.order_id
	JOIN products AS p
        ON oi.product_id = p.product_id
    JOIN categories as cat
        ON p.category_id = cat.category_id

SELECT COUNT(*)
FROM vw_sales_details;

SELECT
    ROUND(SUM(net_amount), 2) AS total_revenue
FROM vw_sales_details
WHERE order_status = 'Completed';

SELECT 
    ROUND(SUM(profit), 2) AS total_profit
FROM vw_sales_details
WHERE order_status = 'Completed';

SELECT
    category_name,
	ROUND(SUM(net_amount), 2) AS revenue
FROM vw_sales_details
WHERE order_status = 'Completed'
GROUP BY category_name
ORDER BY revenue DESC;

CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
	c.first_name,
	c.last_name,
	c.city,
	c.registration_date,

	COUNT(DISTINCT o.order_id) AS total_orders,

	COUNT(DISTINCT o.order_id)
	    FILTER (WHERE o.order_status = 'Completed')
		AS completed_orders,

	COUNT(DISTINCT o.order_id)
	    FILTER (WHERE o.order_status = 'Cancelled')
		AS cancelled_orders,

    COUNT(DISTINCT o.order_id)
	    FILTER (WHERE o.order_status = 'Pending')
		AS pending_orders,

	ROUND(
        COALESCE(
            SUM(v.net_amount)
			    FILTER (WHERE v.order_status = 'Completed'),
			0
		),
		2
	) AS total_spent,

		ROUND(
        COALESCE(
            SUM(v.profit)
			    FILTER (WHERE v.order_status = 'Completed'),
			0
		),
		2
	) AS total_profit,

		ROUND(
        COALESCE(
            SUM(v.net_amount)
			    FILTER (WHERE v.order_status = 'Completed'),
			0
		)
		/
		NULLIF(
            COUNT(DISTINCT o.order_id)
			    FILTER (WHERE o.order_status = 'Completed'),
			0
		),
		2
	) AS average_order_value

FROM customers AS c

LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN vw_sales_details AS v
    ON o.order_id = v.order_id

GROUP BY
    c.customer_id,
	c.first_name,
	c.last_name,
	c.city,
	c.registration_date;

SELECT *
FROM vw_customer_summary
ORDER BY total_spent DESC;

SELECT COUNT(*)
FROM vw_custommer_summary

CREATE OR REPLACE VIEW vw_product_summary AS
SELECT
    p.product_id,
	p.product_name,
	cat.category_name,
	p.unit_price,
	p.cost_price,

	COUNT(DISTINCT v.order_id)
	    FILTER (WHERE v.order_status = 'Completed')
	    AS completed_orders,

	COALESCE(
        SUM(v.quantity)
		    FILTER (WHERE v.order_status = 'Completed'),
		0
	) AS units_sold,

	ROUND(
        COALESCE(
            SUM(v.net_amount)
			    FILTER (WHERE v.order_status = 'Completed'),
			0
		),
		2
	) AS revenue,

	ROUND(
        COALESCE(
            SUM(v.profit)
			    FILTER (WHERE v.order_status = 'Completed'),
				0
		),
		2
	) AS profit,

	ROUND(
        CASE
		    WHEN COALESCE(
                SUM(v.net_amount)
				    FILTER (WHERE v.order_status = 'Completed'),
				0
			) = 0
			    THEN 0
			ELSE
			   COALESCE(
                   SUM(v.profit)
				       FILTER (WHERE v.order_status = 'Completed'),
				   0
			   )
			   /
			   COALESCE(
                   SUM(v.net_amount)
				       FILTER (WHERE v.order_status = 'Completed'),
				   0
			   )
			   * 100
	    END,
	    2
	) AS profit_margin_percent

FROM products AS p

JOIN categories AS cat
    ON p.category_id = cat.category_id
LEFT JOIN vw_sales_details as v
    ON p.product_id = v.product_id

GROUP BY
    p.product_id,
	p.product_name,
	cat.category_name,
	p.unit_price,
	p.cost_price;

SELECT *
FROM vw_product_summary
ORDER BY revenue DESC;

SELECT COUNT(*)
FROM vw_product_summary;

SELECT *
FROM vw_product_summary
ORDER BY profit_margin_percent DESC;

CREATE OR REPLACE VIEW vw_category_summary AS
SELECT
    cat.category_id,
	cat.category_name,

	COUNT(DISTINCT p.product_id) AS products_count,

	COUNT(DISTINCT v.order_id)
	    FILTER (WHERE v.order_status = 'Completed')
		AS completed_orders,

	COALESCE(
        SUM(v.quantity)
		    FILTER (WHERE v.order_status = 'Completed'),
		0
	) AS units_sold,

	ROUND(
        COALESCE(
            SUM(v.net_amount)
			    FILTER (WHERE v.order_status = 'Completed'),
			0
		),
		2
	) AS revenue,

	ROUND(
        COALESCE(
            SUM(v.profit)
			    FILTER (WHERE v.order_status = 'Completed'),
			0
		),
		2
	) AS profit,

	ROUND(
        CASE
		    WHEN COALESCE(
                SUM(v.net_amount)
				    FILTER (WHERE v.order_status = 'Completed'),
				0
			) = 0
			    THEN 0
			ELSE
			   COALESCE(
                   SUM(v.profit)
				       FILTER (WHERE v.order_status = 'Completed'),
				   0
			   )
			   /
			   COALESCE(
                   SUM(v.net_amount)
				       FILTER (WHERE v.order_status = 'Completed'),
				   0
			   )
			   * 100
	    END,
		2
	) AS profit_margin_percent

FROM categories as cat

LEFT JOIN products as p
    ON cat.category_id = p.category_id
LEFT JOIN vw_sales_details AS v
    ON p.product_id = v.product_id

GROUP BY
    cat.category_id,
	cat.category_name;

SELECT *
FROM vw_category_summary
ORDER BY revenue DESC;

SELECT COUNT(*)
FROM vw_category_summary;

CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_TRUNC('month', v.order_date)::DATE AS sales_month,

	COUNT(DISTINCT v.order_id) AS completed_orders,

	SUM(v.quantity) AS units_sold,

	ROUND(
        SUM(v.net_amount),
		2
	) AS revenue,

	ROUND(
        SUM(v.profit),
		2
	) AS profit,

	ROUND(
        AVG(v.net_amount),
		2
	) AS average_line_value,

	ROUND(
        CASE
		    WHEN SUM(v.net_amount) = 0 THEN 0
		    ELSE
			    SUM(v.profit)
				/ SUM(v.net_amount)
				* 100
	    END,
		2
	) AS profit_margin_percent

FROM vw_sales_details AS v

WHERE v.order_status = 'Completed'

GROUP BY 
    DATE_TRUNC('month', v.order_date)

ORDER BY 
    sales_month;

SELECT * 
FROM vw_monthly_sales;

SELECT COUNT(*)
FROM vw_monthly_sales;

CREATE OR REPLACE VIEW vw_city_sales AS
SELECT
    o.shipping_city,

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
	) AS profit,

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

WHERE o.order_status = 'Completed'

GROUP BY
    o.shipping_city

ORDER BY
    revenue DESC;

SELECT *
FROM vw_city_sales;

SELECT COUNT(*)
FROM vw_city_sales;

CREATE OR REPLACE VIEW vw_payment_summary AS
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
	) AS profit,

	ROUND(
        SUM(
            oi.quantity
			* (
               oi.unit_price
			   * (1 - oi.discount_percent / 100)
			   - p.cost_price
			)
		)
		* 100.0
		/
		SUM(
            oi.quantity
			* oi.unit_price
			* (1 - oi.discount_percent / 100)
		),
		2
	) AS profit_margin_percent

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

SELECT *
FROM vw_payment_summary;

SELECT COUNT(*)
FROM vw_payment_summary;

CREATE OR REPLACE VIEW vw_discount_analysis AS
SELECT
    oi.discount_percent,

    COUNT(DISTINCT o.order_id) AS completed_orders,

    SUM(oi.quantity) AS units_sold,

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

SELECT *
FROM vw_discount_analysis;

SELECT COUNT(*)
FROM vw_discount_analysis;

SELECT *
FROM vw_sales_details;





	