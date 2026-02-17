-- Очищенное представление таблицы покупателей
CREATE OR REPLACE VIEW team_6_cleared_customers AS
SELECT DISTINCT
	customer_id,
	customer_unique_id,
	customer_city,
	customer_state
FROM stg.customers
