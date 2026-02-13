-- Создание таблицы узлов
CREATE SCHEMA IF NOT EXISTS team_rksi;
DROP TABLE team_rksi.team_rksi_graph_nodes;
CREATE TABLE IF NOT EXISTS team_rksi.team_rksi_graph_nodes (
	node_id SERIAL PRIMARY KEY,
	node_label TEXT
);

-- Наполнение таблицы категориями товаров
INSERT INTO team_rksi.team_rksi_graph_nodes (node_label)
SELECT DISTINCT product_category_name 
FROM stg.products
WHERE product_category_name IS NOT NULL;

-- Проверка наполнения
SELECT * FROM team_rksi.team_rksi_graph_nodes;