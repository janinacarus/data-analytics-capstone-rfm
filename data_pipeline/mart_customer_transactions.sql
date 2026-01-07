-- ********************************************
-- create mart_customer_transactions
-- ********************************************

-- for updating table
DROP TABLE IF EXISTS mart_customer_transactions;

-- creating table
CREATE TABLE mart_customer_transactions AS
WITH orders AS(
SELECT 
	po.order_id,
	po.customer_id AS order_customer_id,
	DATE(po.order_purchase_timestamp)	AS order_date	
FROM prep_orders po  													-- 99.441 orders / rows
WHERE po.order_status != 'canceled'										-- 625 cancelled orders, but no returns available in dataset
)																		-- 98.816 orders
, adding_customers AS(
SELECT 
	o.order_id,
	o.order_date, 
	pc.customer_unique_id AS customer_id_unique
FROM orders o
JOIN prep_customers pc ON o.order_customer_id = pc.customer_id
)																		-- 98.816 orders (all merged)
SELECT 
	ac.*,
	poi.seller_id,
	sum(price*count) AS total_item_value,
	sum(freight_value*count) AS total_freight_value,
	sum(price*count) + sum(freight_value*count) AS total_order_value
FROM adding_customers ac
JOIN prep_order_items poi USING (order_id)
GROUP BY order_id,seller_id, order_date, customer_id_unique;						-- 98.205 orders (611 lost) / 99,549 rows (some orders have multiple sellers -> multiple rows)

-- granting access table
GRANT ALL PRIVILEGES ON TABLE team_jjat.mart_customer_transactions TO jingwang, anafilip, tetyanashcherbinina, janinacarus;