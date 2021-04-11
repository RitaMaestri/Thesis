#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar  4 11:11:29 2021

@author: rita
"""


import networkx as nx
import pandas as pd


node_list=pd.read_csv("node_list.csv")
network = pd.read_csv("directed-undirected-network.csv")

constructor= nx.MultiDiGraph()
G=nx.from_pandas_edgelist(network, source='source', target='target', edge_attr=["weight", "breed"], create_using=constructor)

attributes = node_list.set_index('nodes').T.to_dict()
print(attributes)
nx.set_node_attributes(G, attributes)

list(G.nodes(data=True))

for (u, v) in G.edges():
    print(G.get_edge_data(u,v))

nx.write_graphml(G, "directed-undirected-network.graphml")
