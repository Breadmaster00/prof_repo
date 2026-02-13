CREATE OR REPLACE VIEW team_rksi.team_rksi_cleared_order_items AS
SELECT DISTINCT ON (order_id, order_item_id)
	order_id,
	order_item_id,
	product_id,
	seller_id,
	CASE 
	  WHEN price < 0 THEN ABS(price)
	  ELSE price
	END as price,
	freight_value
FROM stg.order_items
ORDER BY order_id, order_item_id, price DESC;