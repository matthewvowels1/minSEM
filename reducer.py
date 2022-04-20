import networkx as nx


def reducer(graph, xs, ys, remove_precision=True):
	reduced_graph = graph.copy()
	reduced_graph.remove_nodes_from(list(nx.isolates(reduced_graph)))

	# remove nodes <after> ys:
	ordering = list(nx.topological_sort(reduced_graph))
	indexes = []
	for var in ys:
		indexes.append(ordering.index(var))

	max_index = max(indexes)
	remove_vars = ordering[max_index + 1:]

	for var in remove_vars:
		reduced_graph.remove_node(var)

	# init confounder dictionary (based on causal paths from root causes)
	confounders = {}
	# init causally relevant variable dictionary
	all_causally_relevant_vars = []
	all_causally_relevant_vars.extend(xs)
	# init causal chain dictionary - this will keep track of children based on root causes
	causal_chain = {}
	for x in xs:
		causal_chain[x] = [x]
		effect_vars = list(nx.descendants(reduced_graph, x))
		# add causally relevant vars to dict of causally relevant vars
		all_causally_relevant_vars.extend(effect_vars)
		all_causally_relevant_vars = list(set(all_causally_relevant_vars))

	# get list of all nodes
	all_nodes = set(list(reduced_graph.nodes))
	# identify list of non-causal nodes
	non_causal_nodes = all_nodes - set(all_causally_relevant_vars)

	for k in range(2):  # while length > 0:

		for x in xs:
			current_cause = causal_chain[x][k]
			if k < 1:
				confounders[x] = []

			conf_vars_ = list(nx.ancestors(reduced_graph, current_cause))
			conf_vars = []
			[conf_vars.append(v) for v in conf_vars_ if v not in all_causally_relevant_vars]

			for potential_confounder in conf_vars:
				pot_conf_descs = list(nx.descendants(reduced_graph, potential_confounder))

				if any(p in pot_conf_descs for p in effect_vars):
					if (potential_confounder not in confounders[x]) and (
							potential_confounder not in all_causally_relevant_vars):
						reduced_graph.remove_edge(potential_confounder, current_cause)
						confounders[x].append(potential_confounder)

			children = list(reduced_graph.successors(current_cause))
			causal_chain[x].extend(children)

		# compile list of all identified confounders
	all_confounders = []
	for key in confounders:
		all_confounders.append(confounders[key])
	all_confounders = set([item for sublist in all_confounders for item in sublist])

	# find remaining nodes which are neither causal nor confounders (e.g. precisions and colliders)
	remaining_nodes = non_causal_nodes - all_confounders

	if remove_precision:  # remove precision vars
		for remaining_node in remaining_nodes:
			# check ancestors and descendents
			remaining_decs = list(nx.descendants(reduced_graph, remaining_node))
			remaining_ancs = list(nx.ancestors(reduced_graph, remaining_node))
			if any(x in remaining_ancs for x in all_confounders) == False:
				reduced_graph.remove_node(remaining_node)

	# finally clean up graph by removing isolated vars
	reduced_graph.remove_nodes_from(list(nx.isolates(reduced_graph)))
	return reduced_graph




