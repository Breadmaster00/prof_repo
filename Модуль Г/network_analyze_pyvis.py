import pandas as pd
import networkx as nx
from sqlalchemy import create_engine
import plotly.graph_objects as go

# 1. Загрузка
engine = create_engine('postgresql://postgres:7681@localhost:5433/prof_db')
nodes = pd.read_sql_table('team_rksi_graph_nodes', engine, schema='team_rksi')
edges = pd.read_sql_table('team_rksi_graph_edges', engine, schema='team_rksi')

# 2. Граф
id_to_label = dict(zip(nodes['node_id'], nodes['node_label']))
G = nx.Graph()
for _, row in edges.iterrows():
    G.add_edge(
        id_to_label[row['source']], 
        id_to_label[row['target']], 
        weight=float(row['weight'])
    )

# 3. Метрики
degrees = nx.degree(G, weight='weight')
betweenness = nx.betweenness_centrality(G, weight='weight')
closeness = nx.closeness_centrality(G, distance='weight')

# 4. Сообщества
try:
    import community as community_louvain
    partition = community_louvain.best_partition(G, weight='weight')
except:
    from networkx.algorithms import community
    comms = list(community.greedy_modularity_communities(G, weight='weight'))
    partition = {}
    for i, comm in enumerate(comms):
        for node in comm:
            partition[node] = i

# 5. Позиционирование
pos = nx.spring_layout(G, seed=42, weight='weight')

# 6. Данные для графика
edge_x, edge_y = [], []
for u, v in G.edges():
    x0, y0 = pos[u]
    x1, y1 = pos[v]
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

node_x = [pos[node][0] for node in G.nodes()]
node_y = [pos[node][1] for node in G.nodes()]

# 7. Создаём график
fig = go.Figure()

# Рёбра - ВСЕ ОДИНАКОВОЙ ТОЛЩИНЫ
fig.add_trace(go.Scatter(
    x=edge_x, y=edge_y,
    line=dict(width=1, color='rgba(150,150,150,0.5)'),
    hoverinfo='none',
    mode='lines'
))

# Узлы с подсказками
node_text = [
    f"<b>{node}</b><br>Сообщество: {partition.get(node,0)}<br>Связей: {degrees[node]:.0f}<br>Betweenness: {betweenness[node]:.3f}"
    for node in G.nodes()
]

fig.add_trace(go.Scatter(
    x=node_x, y=node_y,
    mode='markers+text',
    text=list(G.nodes()),
    textposition="top center",
    hovertext=node_text,
    hoverinfo='text',
    marker=dict(
        showscale=True,
        colorscale='Blues',
        color=[betweenness[node] for node in G.nodes()],
        size=[max(10, degrees[node] / 3) for node in G.nodes()],
        line_width=1
    )
))

# 8. Сохраняем
fig.write_html("team_rksi_plotly.html")
print("Готово: team_rksi_plotly.html")