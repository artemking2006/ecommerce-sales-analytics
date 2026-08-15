CREATE TABLE customers(
   customer_id BIGSERIAL PRIMARY KEY,
   first_name VARCHAR(50) NOT NULL,
   last_name VARCHAR(50) NOT NULL,
   email VARCHAR(255) UNIQUE NOT NULL,
   city VARCHAR(100),
   registration_date DATE NOT NULL
);

CREATE TABLE categories(
    category_id BIGSERIAL PRIMARY KEY,
	category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE products(
    product_id BIGSERIAL PRIMARY KEY,
	product_name VARCHAR(150) NOT NULL,
	category_id BIGINT NOT NULL,
	unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
	cost_price NUMERIC(10, 2) NOT NULL CHECK (cost_price >= 0),
	CONSTRAINT
fk_products_category
        FOREIGN KEY (category_id)
		REFERENCES
categories(category_id)
);

CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
	customer_id BIGINT NOT NULL,
	order_date DATE NOT NULL,
	order_status VARCHAR(30) NOT NULL,
	payment_method VARCHAR(30) NOT NULL,
	shipping_city VARCHAR(100) NOT NULL,
	CONSTRAINT fk_orders_customer
	    FOREIGN KEY (customer_id)
		REFERENCES
customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
	order_id BIGINT NOT NULL,
	product_id BIGINT NOT NULL,
	quantity INTEGER  NOT NULL CHECK (quantity > 0),
	unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
	discount_percent NUMERIC(5, 2) DEFAULT 0
	    CHECK (discount_percent BETWEEN 0 AND 100),
	 CONSTRAINT
fk_order_items_order
        FOREIGN KEY (order_id)
		REFERENCES
orders(order_id),
     CONSTRAINT
fk_order_items_product
        FOREIGN KEY (product_id)
		REFERENCES
products(product_id)
);

INSERT INTO categories (category_name)
VALUES
    ('Laptops'),
	('Smartphones'),
	('Tablets'),
	('Monitors'),
	('Accessories'),
	('Audio'),
	('Gaming'),
	('Smart Home')
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO products (
    product_name,
	category_id,
	unit_price,
	cost_price
)
VALUES
    (
        'Lenovo IdeaPad 5',
		(SELECT category_id FROM categories WHERE category_name = 'Laptops'),
		3299.00,
		2650.00
    ),
	(
        'ASUS TUF GAMING A15',
		(SELECT category_id FROM categories WHERE category_name = 'Laptops'),
		4599.00,
		3720.00
	),
	(
        'MacBook Air M3',
		(SELECT category_id FROM categories WHERE category_name = 'Laptops'),
		5499.00,
		4650.00
    ),
	(
        'Samsung Galaxy S25',
		(SELECT category_id FROM categories WHERE category_name = 'Smartphones'),
		3999.00,
		3250.00
    ),
	(
        'iPhone 16',
		(SELECT category_id FROM categories WHERE category_name = 'Smartphones'),
		4299.00,
		3550.00
    ),
	(
        'Google Pixel 9',
		(SELECT category_id FROM categories WHERE category_name = 'Smartphones'),
		3499.00,
		2820.00
    ),
	(
        'Samsung Galaxy Tab S10',
		(SELECT category_id FROM categories WHERE category_name = 'Tablets'),
		3199.00,
		2540.00
    ),
	(
        'iPad Air',
		(SELECT category_id FROM categories WHERE category_name = 'Tablets'),
		2999.00,
		2440.00
    ),
	(
        'Lenovo Tab P12',
		(SELECT category_id FROM categories WHERE category_name = 'Tablets'),
		1499.00,
		1120.00
    ),
	(
        'Dell UltraSharp 27',
		(SELECT category_id FROM categories WHERE category_name = 'Monitors'),
		2199.00,
		1650.00
    ),
	(
        'LG UltraGear 27',
		(SELECT category_id FROM categories WHERE category_name = 'Monitors'),
		1799.00,
		1360.00
    ),
	(
        'Samsung Odyssey G5',
		(SELECT category_id FROM categories WHERE category_name = 'Monitors'),
		1499.00,
		1130.00
    ),
	(
        'Logitech MX Master 3S',
		(SELECT category_id FROM categories WHERE category_name = 'Accessories'),
		449.00,
		310.00
    ),
	(
        'Keychron K2 Keyboard',
		(SELECT category_id FROM categories WHERE category_name = 'Accessories'),
		399.00,
		270.00
    ),
	(
        'USB-C Hub 8-in-1',
		(SELECT category_id FROM categories WHERE category_name = 'Accessories'),
		249.00,
		145.00
    ),
	(
        'Sony WH-1000XM5',
		(SELECT category_id FROM categories WHERE category_name = 'Audio'),
		1599.00,
		1190.00
    ),
	(
        'JBL Charge 5',
		(SELECT category_id FROM categories WHERE category_name = 'Audio'),
		699.00,
		480.00
    ),
	(
        'Apple AirPods Pro',
		(SELECT category_id FROM categories WHERE category_name = 'Audio'),
		1099.00,
		810.00
    ),
	(
        'PlayStation 5 Slim',
		(SELECT category_id FROM categories WHERE category_name = 'Gaming'),
		2399.00,
		1950.00
    ),
	(
        'Xbox Series X',
		(SELECT category_id FROM categories WHERE category_name = 'Gaming'),
		2499.00,
		2020.00
    ),
	(
        'Nintendo Switch OLED',
		(SELECT category_id FROM categories WHERE category_name = 'Gaming'),
		1599.00,
		1240.00
    ),
	(
        'Philips Hue Starter Kit',
		(SELECT category_id FROM categories WHERE category_name = 'Smart Home'),
		649.00,
		430.00
    ),
	(
        'Google Nest Hub',
		(SELECT category_id FROM categories WHERE category_name = 'Smart Home'),
		499.00,
		330.00
    ),
	(
        'Xiaomi Robot Vacuum',
		(SELECT category_id FROM categories WHERE category_name = 'Smart Home'),
		1299.00,
		920.00
    );

	SELECT
	    p.product_id,
		p.product_name,
		c.category_name,
		p.unit_price,
		p.cost_price,
		p.unit_price - p.cost_price
	AS potential_profit
	FROM products AS p
	JOIN categories AS c
	    ON p.category_id = c.category_id
	ORDER BY c.category_name, p.product_name;

INSERT INTO customers (
    first_name,
	last_name,
	email,
	city,
	registration_date
)
VALUES
    ('Anna', 'Kowalska', 'anna.kowalska@example.com', 'Konin', '2025-01-10'),
    ('Piotr', 'Nowak', 'piotr.nowak@example.com', 'Olsztyn', '2025-01-15'),
    ('Marta', 'Wisniewska', 'marta.wisniewska@example.com', 'Koszlin', '2025-02-03'),
    ('Tomasz', 'Wojcik', 'tomasz.wojcik@example.com', 'Gliwice', '2025-02-20'),
    ('Katarzyna', 'Kaminska', 'katarzyna.kaminska@example.com', 'Bialystok', '2025-03-01'),
    ('Michal', 'Lewandowski', 'michal.lewandowski@example.com', 'Hel', '2025-03-12'),
    ('Agnieszka', 'Zielinska', 'agnieszka.zielinska@example.com', 'Legnica', '2025-03-28'),
    ('Jakub', 'Szymanski', 'jakub.szymanski@example.com', 'Skierniewice', '2025-04-05'),
    ('Monika', 'Dabrowska', 'monika.dabrowska@example.com', 'Gdynia', '2025-04-18'),
    ('Pawel', 'Kozlowski', 'pawel.kozlowski@example.com', 'Bydgoszcz', '2025-05-02'),
    ('Ewa', 'Jankowska', 'ewa.jankowska@example.com', 'Gdansk', '2025-05-15'),
    ('Krzysztof', 'Mazur', 'krzysztof.mazur@example.com', 'Torun', '2025-05-29'),
    ('Natalia', 'Krawczyk', 'natalia.krawczyk@example.com', 'Lublin', '2025-06-10'),
    ('Marcin', 'Piotrowski', 'marcin.piotrowski@example.com', 'Lodz', '2025-06-21'),
    ('Aleksandra', 'Grabowska', 'aleksandra.grabowska@example.com', 'Krakow', '2025-07-03'),
    ('Damian', 'Pawlowski', 'damian.pawlowski@example.com', 'Wroclaw', '2025-07-17'),
    ('Karolina', 'Michalska', 'karolina.michalska@example.com', 'Kutno', '2025-08-01'),
    ('Mateusz', 'Krol', 'mateusz.krol@example.com', 'Poznan', '2025-08-14'),
    ('Julia', 'Wieczorek', 'julia.wieczorek@example.com', 'Warsaw', '2025-09-02'),
    ('Patryk', 'Jablonski', 'patryk.jablonski@example.com', 'Szczecin', '2025-09-19');







