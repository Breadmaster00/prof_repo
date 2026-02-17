-- Очищенное представление позиций заказов
CREATE OR REPLACE VIEW team_6.team_6_cleared_order_items AS
SELECT DISTINCT ON(order_id, order_item_id) -- убираем дубликаты позиций, выбираем с наибольшой ценой
	order_id,
	order_item_id,
	product_id,
	seller_id,
	CASE
	  WHEN price < 0 THEN ABS(price) -- если цена отрицательна, то приводим его к положительному
	  ELSE price
	END as price,
	CASE
	  WHEN freight_value < 0 THEN 0 -- если стоимсоть фрахты ниже нуля приводим к 0
	  ELSE freight_value
	END as freight_value
FROM stg.order_items
ORDER BY order_id, order_item_id, price DESC;