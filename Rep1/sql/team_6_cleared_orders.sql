-- Очищенное представление таблицы заказов
CREATE OR REPLACE VIEW team_6.team_6_cleared_orders AS
SELECT
	order_id,
	customer_id,
	CASE
	  WHEN order_delivered_ts IS NOT NULL THEN 'delivered' -- если дата доставки заказа уже указана, то меняем статус на уже доствлен
	  ELSE order_status -- иначе возвращаем как есть
	END as order_status,
	order_purchase_ts,
	CASE
		-- если дата доставки товара не указана, но статус уже доставлено, то отмечаем рассчитанным временем доставки
		WHEN order_delivered_ts IS NULL AND order_status = 'delivered' THEN order_estimated_delivery_ts
		-- если время доставки раньше чем товар был оформлен, то также меняем на рассчитанное время доставки
		WHEN order_delivered_ts < order_purchase_ts THEN order_estimated_delivery_ts
		ELSE order_delivered_ts -- иначе возвращаем как есть
	END as order_delivered_ts,
	order_estimated_delivery_ts::date -- приводим к типу date, т.к. в данных время не указано
FROM stg.orders;
