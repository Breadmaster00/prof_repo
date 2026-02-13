CREATE OR REPLACE VIEW team_rksi.team_rksi_cleared_customers AS
SELECT DISTINCT
	customer_id,
	customer_unique_id,
	customer_city,
	customer_state
FROM stg.customers;