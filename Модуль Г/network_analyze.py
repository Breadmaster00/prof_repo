import pandas as pd
import networkx as nx
import community as community_louvain
import matplotlib.pyplot as plt
from sqlalchemy import create_engine

engine = create_engine('postgresql://postgres:7681@localhost:5433/prof_db')
nodes = pd.read_sql_table('team_rksi_graph_nodes', engine, schema='team_rksi')
edges = pd.read_sql_table('team_rksi_graph_edges', engine, schema='team_rksi')

G = nx.Graph()

for i, row in nodes.iterrows():
    G.add_node(row['node_id'], label=row['node_label'])

for i, row in edges.iterrows():
    G.add_edge(row['source'], row['target'], weight=row['weight'])
print(G)

degrees = dict(G.degree())


betweenness = nx.betweenness_centrality(G, weight='weight')
closeness = nx.closeness_centrality(G, distance='weight')
partition = community_louvain.best_partition(G, weight='weight')

nodes['degree'] = nodes['node_id'].map(degrees)
nodes['betweenness'] = nodes['node_id'].map(betweenness)
nodes['closeness'] = nodes['node_id'].map(closeness)

plt.figure(figsize=(14, 10))
pos = nx.spring_layout(G, k=1.5, iterations=50)
node_sizes = [degrees[node] * 100 for node in G.nodes()]

# Цвет узла = центральность по посредничеству (градиент)
node_colors = [betweenness[node] for node in G.nodes()]
nodes_draw = nx.draw_networkx_nodes(G, pos, node_size=node_sizes, 
                                   node_color=node_colors, cmap=plt.cm.Blues, 
                                   alpha=0.8)
# Рёбра: толщина = вес
edge_widths = [G[u][v]['weight'] / 20 for u, v in G.edges()]
nx.draw_networkx_edges(G, pos, width=edge_widths, alpha=0.3, edge_color='gray')

# Подписи узлов (только ключевые - с высокой степенью)
labels = {}
for node in G.nodes():
    if degrees[node] > nodes['degree'].quantile(0.75):  # верхние 25%
        labels[node] = nodes.loc[nodes['node_id'] == node, 'node_label'].values[0]

nx.draw_networkx_labels(G, pos, labels, font_size=9)

# Легенда (минимальная)
plt.colorbar(nodes_draw, label='Betweenness Centrality')
plt.title('Сетевой анализ категорий товаров', fontsize=14)
plt.axis('off')
plt.tight_layout()
plt.savefig('figure.svg', dpi=300, bbox_inches='tight')
plt.show()

# 6. Простые рекомендации (основанные только на degree и weight)
print("=== РЕКОМЕНДАЦИИ ===")

# Топ-3 сильные связи (бандлы)
strong_edges = edges.nlargest(3, 'weight')
print("\n1. Бандлы для кросс-села (сильнейшие связи):")
for _, row in strong_edges.iterrows():
    source_name = nodes.loc[nodes['node_id'] == row['source'], 'node_label'].values[0]
    target_name = nodes.loc[nodes['node_id'] == row['target'], 'node_label'].values[0]
    print(f"   • {source_name} + {target_name} ({row['weight']} совместных покупок)")

# Топ-3 популярные категории (кросс-селл)
top_categories = nodes.nlargest(3, 'degree')
print("\n2. Популярные категории для продвижения:")
for _, row in top_categories.iterrows():
    print(f"   • {row['node_label']} ({row['degree']} связей)")

# Топ-3 мостовые категории (точки риска)
top_betweenness = nodes.nlargest(3, 'betweenness')
print("\n3. Критические точки (высокая betweenness centrality):")
for _, row in top_betweenness.iterrows():
    print(f"   • {row['node_label']} - ключевой 'мост' между категориями")