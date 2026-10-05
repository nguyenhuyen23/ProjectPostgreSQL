/*  
 Grain:
 1 dòng mart.fact_sales = 1 order_item
Lợi ích:
- phân tích doanh thu theo sản phẩm;
- phân tích theo category;
- tính quantity, gross, discount, net ở cấp nhỏ nhất;
- sau đó có thể cộng lên customer/date/category.
	   
 */

/* Schema core: dữ liệu sơ cấp
   Schema core: dữ liệu thứ cấp
   
*/

/* Create new schema mart */

create schema if not exists mart;

select * from information_schema.schemata s 
where s.schema_name = 'mart';

/* dim_date */

CREATE TABLE IF NOT EXISTS mart.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_month SMALLINT NOT NULL,
    month_num SMALLINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_num SMALLINT NOT NULL,
    year_num SMALLINT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);


/* dim_customer */

CREATE TABLE IF NOT EXISTS mart.dim_customer (
    customer_sk BIGSERIAL PRIMARY KEY,
    customer_id VARCHAR(12) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    customer_segment VARCHAR(30),
    status VARCHAR(20)
);

/* dim_product */

CREATE TABLE IF NOT EXISTS mart.dim_product (
    product_sk BIGSERIAL PRIMARY KEY,
    product_id VARCHAR(12) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
    category_id VARCHAR(10),
    category_name VARCHAR(120)
);

/* dim_payment_method */

CREATE TABLE IF NOT EXISTS mart.dim_payment_method (
    payment_method_sk SMALLSERIAL PRIMARY KEY,
    payment_method VARCHAR(30) NOT NULL UNIQUE
);

/* dim_order_status */

CREATE TABLE IF NOT EXISTS mart.dim_order_status (
    order_status_sk SMALLSERIAL PRIMARY KEY,
    order_status VARCHAR(20) NOT NULL UNIQUE
);

/* fact_sale */

CREATE TABLE IF NOT EXISTS mart.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,
    order_item_id VARCHAR(16) NOT NULL UNIQUE,
    order_id VARCHAR(12) NOT NULL,
    date_key INTEGER NOT NULL
        REFERENCES mart.dim_date(date_key), ---tham chiếu đến date_key trong bảng dim_date
    customer_sk BIGINT NOT NULL
        REFERENCES mart.dim_customer(customer_sk), --- tham chiếu đến customer_sk trong bảng dim_customer
    product_sk BIGINT NOT NULL
        REFERENCES mart.dim_product(product_sk), --- tham chiếu đến product_sk trong bảng dim_product
    payment_method_sk SMALLINT
        REFERENCES mart.dim_payment_method(payment_method_sk), --- tham chiếu đến payment_method_sk trong bảng dim_payment_method
    order_status_sk SMALLINT NOT null 
        REFERENCES mart.dim_order_status(order_status_sk), --- tham chiếu đến order_status_sk trong bảng dim_order_status
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(14,2) NOT NULL,
    discount_amount NUMERIC(14,2) NOT NULL,
    gross_amount NUMERIC(14,2) NOT NULL,
    net_amount NUMERIC(14,2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date
ON mart.fact_sales(date_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_customer
ON mart.fact_sales(customer_sk);

CREATE INDEX IF NOT EXISTS idx_fact_sales_product
ON mart.fact_sales(product_sk);


TRUNCATE
    mart.fact_sales,
    mart.dim_customer,
    mart.dim_product,
    mart.dim_payment_method,
    mart.dim_order_status
RESTART IDENTITY CASCADE;

INSERT INTO mart.dim_date(
    date_key,
    full_date,
    day_of_month,
    month_num,
    month_name,
    quarter_num,
    year_num,
    is_weekend
)
SELECT
    to_char(d,'YYYYMMDD')::int,
    d::date,
    extract(day from d),
    extract(month from d),
    trim(to_char(d,'Month')),
    extract(quarter from d),
    extract(year from d),
    extract(isodow from d) IN (6,7)
FROM generate_series(
    '2025-01-01'::date,
    '2027-12-31'::date,
    '1 day'
) d
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO mart.dim_customer(
    customer_id,
    full_name,
    city,
    customer_segment,
    status
)
SELECT
    customer_id,
    full_name,
    city,
    customer_segment,
    status
FROM core.customers;


INSERT INTO mart.dim_product(
    product_id,
    product_name,
    category_id,
    category_name
)
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    c.category_name
FROM core.products p
JOIN core.categories c
USING(category_id);


INSERT INTO mart.dim_payment_method(payment_method)
VALUES
    ('cash'),
    ('bank_transfer'),
    ('card'),
    ('e_wallet')
ON CONFLICT DO NOTHING;


INSERT INTO mart.dim_order_status(order_status)
VALUES
    ('pending'),
    ('confirmed'),
    ('shipped'),
    ('completed'),
    ('cancelled')
ON CONFLICT DO NOTHING;


INSERT INTO mart.fact_sales(
    order_item_id,
    order_id,
    date_key,
    customer_sk,
    product_sk,
    payment_method_sk,
    order_status_sk,
    quantity,
    unit_price,
    discount_amount,
    gross_amount,
    net_amount
)
SELECT
    oi.order_item_id,
    o.order_id,
    to_char(o.order_date,'YYYYMMDD')::int,
    dc.customer_sk,
    dp.product_sk,
    dpm.payment_method_sk,
    dos.order_status_sk,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.quantity * oi.unit_price AS gross_amount,
    oi.quantity * oi.unit_price
        - oi.discount_amount AS net_amount
FROM core.order_items oi
JOIN core.orders o
USING(order_id)
JOIN mart.dim_customer dc
ON dc.customer_id = o.customer_id
JOIN mart.dim_product dp
ON dp.product_id = oi.product_id
JOIN mart.dim_order_status dos
ON dos.order_status = o.status
LEFT JOIN LATERAL (
    SELECT payment_method
    FROM core.payments p
    WHERE p.order_id = o.order_id
    ORDER BY payment_date DESC
    LIMIT 1
) lp
ON true
LEFT JOIN mart.dim_payment_method dpm
ON dpm.payment_method = lp.payment_method
ON CONFLICT (order_item_id) DO NOTHING;
