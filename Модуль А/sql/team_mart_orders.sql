CREATE TABLE IF NOT EXISTS team_rksi.team_rksi_mart_orders (
    order_id 			text PRIMARY KEY,
    order_status 		text,
    order_purchase_ts 	timestamp,
    order_month_year 	date,
    order_delivered_ts 	timestamp,
	order_estimated_date date,
    delivery_days 		integer,
	
    customer_unique_id  text,
	customer_city 		text,
    customer_state 		text,

	order_price 		numeric(18, 2),
	order_freight 		numeric(18, 2),
	order_total 		numeric(18, 2),

	paid_total 			numeric(18, 2),

	review_score		integer   
);


WITH agg_order_items AS (
	SELECT
		order_id,
		SUM(price) as order_price,
		SUM(freight_value) as order_freight,
		SUM(price) + SUM(freight_value) as order_total
	FROM team_rksi.team_rksi_cleared_order_items
	GROUP BY order_id
), 

agg_payments AS (
	SELECT 
		order_id,
		SUM(payment_value) as paid_total
	FROM team_rksi.team_rksi_cleared_payments
	GROUP BY order_id

)
INSERT INTO team_rksi.team_rksi_mart_orders(
	order_id,
    order_status,
    order_purchase_ts,
    order_month_year,
    order_delivered_ts,
	order_estimated_date,
    delivery_days,
    customer_unique_id,
	customer_city,
    customer_state,
	order_price,
	order_freight,
	order_total,
	paid_total,
	review_score 
)
SELECT
	order_id,
    order_status,
    order_purchase_ts,
    date_trunc('month', order_purchase_ts)::date as order_month_year,
    order_delivered_ts,
	order_estimated_delivery_ts,
    date_trunc('day', order_delivered_ts - order_purchase_ts)::integer as delivery_days,
    customer_unique_id,
	customer_city,
    customer_state,
	order_price,
	order_freight,
	order_total,
	paid_total,
	review_score
FROM team_rksi.team_rksi_cleared_orders
JOIN team_rksi.team_rksi_cleared_customers USING(customer_id)
LEFT JOIN agg_order_items USING(order_id)
LEFT JOIN agg_payments USING(order_id)
LEFT JOIN team_rksi.team_rksi_cleared_reviews USING(order_id)
ORDER BY order_purchase_ts

ON CONFLICT(order_id) DO UPDATE
SET 
	order_id = EXCLUDED.order_id,
    order_status = EXCLUDED.order_status,
    order_purchase_ts = EXCLUDED.order_purchase_ts,
    order_month_year = EXCLUDED.order_month_year,
    order_delivered_ts = EXCLUDED.order_delivered_ts,
	order_estimated_date = EXCLUDED.order_estimated_date,
    delivery_days = EXCLUDED.delivery_days,
    customer_unique_id = EXCLUDED.customer_unique_id,
	customer_city = EXCLUDED.customer_city,
    customer_state = EXCLUDED.customer_state,
	order_price = EXCLUDED.order_price,
	order_freight = EXCLUDED.order_freight,
	order_total = EXCLUDED.order_total,
	paid_total = EXCLUDED.paid_total,
	review_score = EXCLUDED.review_score;

select * from team_rksi.team_rksi_mart_orders
order by order_purchase_ts;
-- drop table team_rksi.team_rksi_mart_orders;
