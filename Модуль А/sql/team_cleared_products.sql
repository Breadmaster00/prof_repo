CREATE OR REPLACE VIEW team_rksi.team_rksi_cleared_products AS 
SELECT
	product_id,
	CASE
	  WHEN product_category_name IS NULL THEN 'other'
	  ELSE product_category_name
	END,
	product_weight_g
FROM stg.products;	