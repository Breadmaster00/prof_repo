CREATE TABLE IF NOT EXISTS team_rksi.team_rksi_mart_sales2 (
    order_id            		text,
	order_item_id       		integer,
	product_id					text,
	product_category_name		text,
	product_weight_g			integer,
	seller_id					text,
	price						numeric(18, 2),
	freight_value				numeric(18, 2),
	price_total					numeric(18, 2),
	
	order_status				text,
	order_purchase_ts			timestamp,
	order_purchase_month		date,
	order_delivered_ts			timestamp,
	order_estimated_date		date,
	delivery_days				integer,

	customer_unique_id			text,
	customer_city				text,
	customer_state				text,

	review_score				integer,
	PRIMARY KEY (order_id, order_item_id)
);

INSERT INTO team_rksi.team_rksi_mart_sales2 (
	order_id,
	order_item_id,
	product_id,
	product_category_name,
	product_weight_g,
	seller_id,
	price,
	freight_value,
	price_total,
	order_status,
	order_purchase_ts,
	order_purchase_month,
	order_delivered_ts,
	order_estimated_date,
	delivery_days,
	customer_unique_id,
	customer_city,
	customer_state,
	review_score
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
	price + freight_value as price_total,
	order_status,
	order_purchase_ts,
	date_trunc('month', order_purchase_ts) as order_purchase_month,
	order_delivered_ts,
	order_estimated_delivery_ts::date as order_estimated_date,
	extract(DAY FROM order_delivered_ts - order_purchase_ts)::integer as delivery_days,
	customer_unique_id,
	customer_city,
	customer_state,
	review_score
FROM team_rksi.team_rksi_cleared_orders
JOIN team_rksi.team_rksi_cleared_order_items USING(order_id)
LEFT JOIN team_rksi.team_rksi_cleared_products USING(product_id)
LEFT JOIN team_rksi.team_rksi_cleared_customers USING(customer_id)
LEFT JOIN team_rksi.team_rksi_cleared_reviews USING(order_id)

ON CONFLICT(order_id, order_item_id) DO UPDATE 
SET
	order_id = EXCLUDED.order_id,
	order_item_id = EXCLUDED.order_item_id,
	product_id = EXCLUDED.product_id,
	product_category_name = EXCLUDED.product_category_name,
	product_weight_g = EXCLUDED.product_weight_g,
	seller_id = EXCLUDED.seller_id,
	price = EXCLUDED.price,
	freight_value = EXCLUDED.freight_value,
	price_total = EXCLUDED.price_total,
	order_status = EXCLUDED.order_status,
	order_purchase_ts = EXCLUDED.order_purchase_ts,
	order_purchase_month = EXCLUDED.order_purchase_month,
	order_delivered_ts = EXCLUDED.order_delivered_ts,
	order_estimated_date = EXCLUDED.order_estimated_date,
	delivery_days = EXCLUDED.delivery_days,
	customer_unique_id = EXCLUDED.customer_unique_id,
	customer_city = EXCLUDED.customer_city,
	customer_state = EXCLUDED.customer_state,
	review_score = EXCLUDED.review_score;

select * from team_rksi.team_rksi_mart_sales2;