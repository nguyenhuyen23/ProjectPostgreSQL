
CREATE TABLE IF NOT EXISTS categories (
  category_id varchar(10) PRIMARY KEY,
  category_name varchar(120) NOT NULL,
  parent_category_id varchar(10) NOT NULL,
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id varchar(12) PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(200) UNIQUE NOT NULL,
  phone varchar(30),
  city varchar(100),
  customer_segment varchar(30) NOT NULL,
  status varchar(20) NOT NULL,
  source_system varchar(50) NOT NULL DEFAULT 'unknown',
  ingested_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
  product_id varchar(12) PRIMARY KEY,
  category_id varchar(10) NOT NULL,
  product_name varchar(200) NOT NULL,
  unit_price numeric(14,2) NOT NULL,
  cost_price Numeric(14,2) NOT NULL,
  status varchar(20) NOT NULL,
  source_system varchar(50) NOT NULL DEFAULT 'unknown',
  ingested_at timestamp NOT NULL DEFAULT now(),
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
  order_id varchar(12) PRIMARY KEY,
  customer_id varchar(12) NOT NULL,
  order_date timestamp NOT NULL,
  status varchar(20) NOT NULL,
  shipping_city varchar(100),
  channel varchar(20) NOT NULL,
  order_total NUMERIC(14,2) NOT NULL CHECK (order_total >= 0),
  source_system varchar(50) NOT NULL DEFAULT 'unknown',
  ingested_at timestamp NOT NULL DEFAULT now(),
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id varchar(16) PRIMARY KEY,
  order_id varchar(12) NOT NULL,
  product_id varchar(12) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
  discount_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  source_system varchar(50) NOT NULL DEFAULT 'unknown',
  ingested_at timestamp NOT NULL DEFAULT now(),
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id VARCHAR(12) PRIMARY KEY,
  order_id VARCHAR(12) NOT NULL,
  payment_date timestamp NOT NULL,
  payment_method VARCHAR(30) NOT NULL,
  payment_status VARCHAR(20) NOT NULL,
  amount NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
  source_system VARCHAR(50) NOT NULL DEFAULT 'unknown',
  ingested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS orders_status (
  status varchar(20) NOT NULL
);


ALTER TABLE categories ADD FOREIGN KEY (parent_category_id) REFERENCES categories (category_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE products ADD FOREIGN KEY (category_id) REFERENCES categories (category_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers (customer_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE order_items ADD FOREIGN KEY (order_id) REFERENCES orders (order_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE order_items ADD FOREIGN KEY (product_id) REFERENCES products (product_id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE payments ADD FOREIGN KEY (order_id) REFERENCES orders (order_id) DEFERRABLE INITIALLY IMMEDIATE;
