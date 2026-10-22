-- Build the project's customer and product dimensions and order-item fact table.
-- Prerequisite: supply_chain_db.staging_supply_chain is loaded.
-- WARNING: This script drops and recreates dim_customers, dim_products, and fact_orders.

CREATE DATABASE IF NOT EXISTS supply_chain_db;
USE supply_chain_db;

DROP TABLE IF EXISTS dim_customers;
CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    customer_fname VARCHAR(100),
    customer_lname VARCHAR(100),
    customer_city VARCHAR(100),
    customer_state VARCHAR(50)
);

INSERT INTO dim_customers (customer_id, customer_fname, customer_lname, customer_city, customer_state)
SELECT DISTINCT
    CAST(customer_id AS UNSIGNED),
    customer_fname,
    customer_lname,
    customer_city,
    customer_state
FROM staging_supply_chain
WHERE customer_id REGEXP '^[0-9]+$';

DROP TABLE IF EXISTS dim_products;
CREATE TABLE dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_name VARCHAR(100),
    product_price DOUBLE
);

INSERT INTO dim_products (product_id, product_name, category_name, product_price)
SELECT DISTINCT
    CAST(product_card_id AS UNSIGNED),
    product_name,
    category_name,
    CAST(product_price AS DOUBLE)
FROM staging_supply_chain
WHERE product_card_id REGEXP '^[0-9]+$'
  AND product_price REGEXP '^[0-9.]+$';

-- One row per order item in the source, despite the table name fact_orders.
DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders (
    order_id INT,
    customer_id INT,
    product_id INT,
    order_date DATE,
    shipping_date DATE,
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    sales_amount DOUBLE,
    benefit_per_order DOUBLE,
    delivery_status VARCHAR(100),
    order_status VARCHAR(50),
    shipping_mode VARCHAR(100)
);

INSERT INTO fact_orders
SELECT
    CAST(order_id AS UNSIGNED),
    CAST(customer_id AS UNSIGNED),
    CAST(product_card_id AS UNSIGNED),
    STR_TO_DATE(order_date_text, '%m/%d/%Y %H:%i'),
    STR_TO_DATE(shipping_date_text, '%m/%d/%Y %H:%i'),
    CAST(days_for_shipping_real AS SIGNED),
    CAST(days_for_shipment_scheduled AS SIGNED),
    CAST(sales AS DOUBLE),
    CAST(benefit_per_order AS DOUBLE),
    delivery_status,
    order_status,
    shipping_mode
FROM staging_supply_chain
WHERE order_id REGEXP '^[0-9]+$'
  AND customer_id REGEXP '^[0-9]+$'
  AND product_card_id REGEXP '^[0-9]+$'
  AND order_date_text IS NOT NULL AND order_date_text <> ''
  AND shipping_date_text IS NOT NULL AND shipping_date_text <> '';

-- Smoke-check that fact rows can resolve to both dimensions.
SELECT f.order_id, f.order_date, c.customer_city, p.product_name,
       f.sales_amount, f.delivery_status
FROM fact_orders AS f
JOIN dim_customers AS c ON f.customer_id = c.customer_id
JOIN dim_products AS p ON f.product_id = p.product_id
LIMIT 5;
