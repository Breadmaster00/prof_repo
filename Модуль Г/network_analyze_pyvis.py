import pandas as pd
import networkx as nx
from sqlalchemy import create_engine
from pyvis.network import Network

# 1. Подключение к базе
engine = create_engine('postgresql://postgres:7681@localhost:5432/prof_db')

# 2. Загрузка данных
nodes = pd.read_sql_table('team_rksi_graph_nodes', engine, schema='team_rksi')
edges = pd.read_sql_table('team_rksi_graph_edges', engine, schema='team_rksi')

# 3. Создаём словарь для быстрого доступа к названиям
id_to_label = dict(zip(nodes['node_id'], nodes['node_label']))

# 4. Строим граф с названиями категорий (удобнее для визуализации)
G = nx.Graph()

# Добавляем рёбра сразу с названиями
for _, row in edges.iterrows():
    source_name = id_to_label[row['source']]
    target_name = id_to_label[row['target']]
    G.add_edge(source_name, target_name, weight=row['weight'])

print(f"Граф построен: {G.number_of_nodes()} узлов, {G.number_of_edges()} рёбер")

# 5. Рассчитываем метрики
degrees = nx.degree(G, weight='weight')  # Взвешенная степень
betweenness = nx.betweenness_centrality(G, weight='weight')
closeness = nx.closeness_centrality(G, distance='weight')


# 6. Создаём интерактивный граф PyVis
net = Network(
    height='750px',
    width='100%',
    bgcolor='#ffffff',
    font_color='#333333'
)

# Настраиваем физику (чтобы граф был красивым)
net.repulsion(
    node_distance=200,
    central_gravity=0.2,
    spring_length=150,
    spring_strength=0.05,
    damping=0.09
)

# 7. Добавляем узлы с атрибутами
for node in G.nodes():
    # Определяем цвет сообщества
    community_colors = [
        '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
        '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9'
    ]
    color = community_colors[partition[node] % len(community_colors)]
    
    # Размер узла = взвешенная степень
    size = max(20, min(80, degrees[node] * 0.5))
    
    # Подсказка при наведении
    hover_text = f"""
    <b>{node}</b><br>
    Сообщество: {partition[node]}<br>
    Связей: {G.degree(node)}<br>
    Вес связей: {degrees[node]:.1f}<br>
    Betweenness: {betweenness[node]:.3f}<br>
    Closeness: {closeness[node]:.3f}    
    """
    
    net.add_node(
        node,
        label=node,
        title=hover_text,
        size=size,
        color=color,
        borderWidth=2
    )

# 8. Добавляем рёбра
for u, v, data in G.edges(data=True):
    weight = data.get('weight', 1)
    
    # Толщина линии = вес связи
    width = max(1, min(5, weight / 20))
    
    # Цвет ребра в зависимости от силы связи
    if weight > 50:
        edge_color = '#FF4444'
    elif weight > 20:
        edge_color = '#FFA726'
    else:
        edge_color = '#42A5F5'
    
    net.add_edge(
        u, v,
        value=width,
        title=f"Совместных покупок: {weight}",
        color=edge_color
    )

# 9. Настраиваем интерфейс
net.show_buttons(filter_=['physics', 'nodes', 'edges', 'layout', 'interaction'])

# 10. Сохраняем
output_file = 'team_rksi_graph.html'
net.save_graph(output_file)
print(f"✅ Интерактивный граф сохранён: {output_file}")

# 11. Выводим рекомендации
print("\n" + "="*60)
print("АНАЛИТИЧЕСКИЕ ВЫВОДЫ И РЕКОМЕНДАЦИИ")
print("="*60)

# Топ-5 самых сильных связей (бандлы)
sorted_edges = sorted(G.edges(data=True), 
                     key=lambda x: x[2].get('weight', 0), 
                     reverse=True)[:5]
print("\n🎯 ТОП-5 бандлов для кросс-села:")
for i, (u, v, data) in enumerate(sorted_edges, 1):
    print(f"  {i}. {u} + {v}: {data['weight']} совместных покупок")

# Топ-5 самых связанных категорий
sorted_degrees = sorted(degrees.items(), key=lambda x: x[1], reverse=True)[:5]
print("\n🏆 Самые популярные категории:")
for i, (cat, score) in enumerate(sorted_degrees, 1):
    print(f"  {i}. {cat}: {score:.1f} суммарный вес связей")

# Топ-5 мостовых категорий (точки риска)
sorted_betweenness = sorted(betweenness.items(), key=lambda x: x[1], reverse=True)[:5]
print("\n⚠️  Критические точки (мостовые категории):")
for i, (cat, score) in enumerate(sorted_betweenness, 1):
    print(f"  {i}. {cat}: betweenness = {score:.3f}")

# Анализ сообществ
print("\n👥 Обнаруженные сообщества (готовые наборы):")
community_groups = {}
for node, comm_id in partition.items():
    community_groups.setdefault(comm_id, []).append(node)

for comm_id, categories in community_groups.items():
    if len(categories) >= 3:  # Показываем только группы из 3+ категорий
        print(f"  • Сообщество {comm_id}: {', '.join(categories[:5])}")
        if len(categories) > 5:
            print(f"    ... и ещё {len(categories) - 5} категорий")

print("\n" + "="*60)
print("📊 МЕТРИКИ СЕТИ:")
print(f"  • Узлов (категорий): {G.number_of_nodes()}")
print(f"  • Рёбер (связей): {G.number_of_edges()}")
print(f"  • Плотность сети: {nx.density(G):.3f}")
print(f"  • Обнаружено сообществ: {len(set(partition.values()))}")
print("="*60)
print("📁 Файлы:")
print(f"  • team_rksi_graph.html - интерактивный граф (открыть в браузере)")
print("="*60)