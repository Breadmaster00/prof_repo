/* Очищенное представление таблицы продуктов */
CREATE OR REPLACE VIEW team_6.team_6_cleared_products AS
SELECT
	product_id,
	CASE  -- Заменяем NULL значения категории товаров на 'other'
	  WHEN product_category_name IS NULL THEN 'other'
	  ELSE product_category_name
	END,
	product_weight_g
FROM stg.products