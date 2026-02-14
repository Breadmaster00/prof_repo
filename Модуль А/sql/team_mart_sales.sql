CREATE TABLE IF NOT EXISTS team_rksi.team_rksi_mart_sales (
	order_id 				text,
	order_item_id   		integer,
	product_id				text,
	product_category_name	text,
	product_weight_g		integer,
	seller_id				text,
	price					numeric(18, 2),
	freight_value			numeric(18, 2),
	total_price				numeric(18, 2),

	customer_unique_id		text,
	customer_city			text,
	customer_state			text,

	purchase_month			date,
	PRIMARY KEY (order_id, order_item_id)
);

INSERT INTO team_rksi.team_rksi_mart_sales (
	order_id,
	order_item_id,
	product_id,
	product_category_name,
	product_weight_g,
	seller_id,
	price,
	freight_value,
	total_price,
	customer_unique_id,
	customer_city,
	customer_state,
	purchase_month
)
SELECT 
	order_id,
	order_item_id,
	product_id,
	product_category_name,
	product_weight_g,
	seller_id,
	price,
	freight_value,
	price + freight_value as total_price,
	customer_unique_id,
	customer_city,
	customer_state,
	date_trunc('month', order_purchase_ts)::date as purchase_month
FROM team_rksi.team_rksi_cleared_order_items
JOIN team_rksi.team_rksi_cleared_orders USING(order_id)
JOIN team_rksi.team_rksi_cleared_products USING(product_id)
JOIN team_rksi.team_rksi_cleared_customers USING(customer_id)

ON CONFLICT (order_id, order_item_id) DO UPDATE
SET
	order_id = EXCLUDED.order_id,
	order_item_id = EXCLUDED.order_item_id,
	product_id = EXCLUDED.product_id,
	product_category_name = EXCLUDED.product_category_name,
	product_weight_g = EXCLUDED.product_weight_g,
	seller_id = EXCLUDED.seller_id,
	price = EXCLUDED.price,
	freight_value = EXCLUDED.freight_value,
	customer_unique_id = EXCLUDED.customer_unique_id,
	customer_city = EXCLUDED.customer_city,
	customer_state = EXCLUDED.customer_state,
	purchase_month = EXCLUDED.purchase_month