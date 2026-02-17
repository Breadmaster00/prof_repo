-- Расчёт погрешности расчётов
select
	'Количество значений 0 цены в team_6_cleared_order_items' as "Вид пропущенных значений",
	ROUND((
	select count(*) from team_6.team_6_cleared_order_items
	where price = 0
	) * 100.0 / count(*), 2) as "Процент от общего количества"
FROM team_6.team_6_cleared_order_items
UNION
select
	'Количество значений 0 стоимости фрахты в team_6_cleared_order_items' ,
	ROUND((
	select count(*) from team_6.team_6_cleared_order_items
	where freight_value = 0
	) * 100.0 / count(*), 2)
FROM team_6.team_6_cleared_order_items
UNION 
SELECT 
	'Количество значений 0 веса продукта в team_6_cleared_products',
	ROUND((
	SELECT COUNT(*) FROM team_6.team_6_cleared_products
	WHERE product_weight_g = 0
	) * 100.0 / COUNT(*), 2)
FROM team_6.team_6_cleared_products;