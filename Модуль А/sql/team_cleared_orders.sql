CREATE OR REPLACE VIEW team_rksi.team_rksi_cleared_orders AS
SELECT
	order_id,
	customer_id,
    CASE 
	  WHEN order_delivered_ts IS NOT NULL THEN 'delivered'
	  ELSE order_status
	END as order_status,
	order_purchase_ts,
    CASE
	  WHEN order_delivered_ts IS NULL AND order_status = 'delivered' THEN order_estimated_delivery_ts
	  WHEN order_delivered_ts < order_purchase_ts THEN order_estimated_delivery_ts
	  ELSE order_delivered_ts 
	END as order_delivered_ts,
	order_estimated_delivery_ts::date
FROM stg.orders;
