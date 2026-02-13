-- Создание таблицы рёбер
CREATE TABLE IF NOT EXISTS team_rksi.team_rksi_graph_edges (
	edge_id SERIAL PRIMARY KEY,
	source INT REFERENCES team_rksi.team_rksi_graph_nodes(node_id),
	target INT REFERENCES team_rksi.team_rksi_graph_nodes(node_id),
	weight INT
);

-- Наполнение таблицы
INSERT INTO team_rksi.team_rksi_graph_edges (source, target, weight)
WITH oi_with_category AS (
	select product_id, order_id, product_category_name from stg.order_items
	join stg.products USING(product_id)
)
SELECT
	gn1.node_id as source,
	gn2.node_id as target,
	COUNT(*) weight
FROM 
	oi_with_category AS oi1
	JOIN oi_with_category AS oi2 USING(order_id)
	/* 
	присоединения ниже нужны для того, чтобы сопоставить название с айди из таблицы узлов,
	если что можно будет передаласть, как раньше
	*/
	JOIN team_rksi.team_rksi_graph_nodes AS gn1 ON gn1.node_label = oi1.product_category_name
	JOIN team_rksi.team_rksi_graph_nodes AS gn2 ON gn2.node_label = oi2.product_category_name
WHERE 
	oi1.product_id <> oi2.product_id 
	AND oi1.product_category_name > oi2.product_category_name
GROUP BY 1, 2;

-- Проверка наполнения
select * from team_rksi.team_rksi_graph_edges;