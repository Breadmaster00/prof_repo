-- Создаём витрину по позициям заказа
-- Подробное описание каждого атрибута в DataQuality-отчёте
CREATE TABLE IF NOT EXISTS team_6.team_6_mart_sales (
	order_id					text,
	order_item_id				text,
	seller_id					text,
	order_status				text,
	order_purchase_ts			timestamp,
	order_month_purchase_date	date,
	order_purchase_date			date,
	order_delivered_ts			timestamp,
	delivery_days				integer,

	product_category_name		text,
	product_weight_g			integer,

	price						numeric(18, 2),
	freight_value				numeric(18, 2),
	price_total					numeric(18, 2),
	
	customer_unique_id			text,
	customer_city				text,
	customer_state				text,

	review_score				integer,
	PRIMARY KEY (order_id, order_item_id)
);

-- Вносим изменения + создаём инкриментальную загрузку при помощи upsert
INSERT INTO team_6.team_6_mart_sales (
	order_id,
	order_item_id,
	seller_id,
	order_status,
	order_purchase_ts,
	order_month_purchase_date,
	order_purchase_date,
	order_delivered_ts,
	delivery_days,
	product_category_name,
	product_weight_g,
	price,
	freight_value,
	price_total,
	customer_unique_id,
	customer_city,
	customer_state,
	review_score
)
SELECT
	order_id,
	order_item_id,
	seller_id,
	order_status,
	order_purchase_ts,
	date_trunc('month', order_purchase_ts) as order_month_purchase_date, -- приводим дату к месяцу
	date_trunc('day', order_purchase_ts) as order_purchase_date, -- приводим дату к дню
	order_delivered_ts,
	extract(day from order_delivered_ts - order_purchase_ts)::integer as delivery_days, -- считаем время доставки
	product_category_name,
	product_weight_g,
	price,
	freight_value,
	price + freight_value as price_total,
	customer_unique_id,
	customer_city,
	customer_state,
	review_score
FROM team_6.team_6_cleared_order_items
JOIN team_6.team_6_cleared_orders USING(order_id)
LEFT JOIN team_6.team_6_cleared_customers USING(customer_id)
LEFT JOIN team_6.team_6_cleared_products USING(product_id)
LEFT JOIN team_6.team_6_cleared_reviews USING(order_id)

-- Если строка с таким айди заказа и позиции заказа уже существует, то обновляем поля этой строки
ON CONFLICT (order_id, order_item_id) DO UPDATE
SET seller_id = EXCLUDED.seller_id,
	order_status = EXCLUDED.order_status,
	order_purchase_ts = EXCLUDED.order_purchase_ts,
	order_month_purchase_date = EXCLUDED.order_month_purchase_date,
	order_purchase_date = EXCLUDED.order_purchase_date,
	order_delivered_ts = EXCLUDED.order_delivered_ts,
	delivery_days = EXCLUDED.delivery_days,
	product_category_name = EXCLUDED.product_category_name,
	product_weight_g = EXCLUDED.product_weight_g,
	price = EXCLUDED.price,
	freight_value = EXCLUDED.freight_value,
	price_total = EXCLUDED.price_total,
	customer_unique_id = EXCLUDED.customer_unique_id,
	customer_city = EXCLUDED.customer_city,
	customer_state = EXCLUDED.customer_state,
	review_score = EXCLUDED.review_score;