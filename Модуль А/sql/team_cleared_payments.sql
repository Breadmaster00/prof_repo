CREATE OR REPLACE VIEW team_rksi.team_rksi_cleared_payments AS
SELECT DISTINCT
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value
FROM stg.payments
ORDER BY 1, 2
