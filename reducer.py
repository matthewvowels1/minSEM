import networkx as nx

def reducer(graph, xs, ys):

	reduced_graph = nx.DiGraph()

	desired_paths = []
	for x, y in zip(xs, ys):
		desired_paths.append(list(nx.all_simple_paths(graph, x, y)))

	desired_vars = []
	for desired_path in desired_paths:
		for path in desired_path:
			edges = len(path)
			desired_vars.append(v for v in path)
			for i in range(1, edges):
				reduced_graph.add_edge(path[i - 1], path[i])

	desired_paths = list(reduced_graph.edges())
	desired_vars = set([item for sublist in desired_paths for item in sublist])

	all_predecs = []
	for desired_var in desired_vars:  # for each desired variable
		predecs = list(graph.predecessors(desired_var))  # get desired var predecessors
		all_predecs.append(
			[p for p in predecs if p not in desired_vars])  # remove the predecessors which are desired variable
	all_predecs = set([item for sublist in all_predecs for item in sublist])

	routes = {}  # this will store all the ways a predec can connect to a desired variable
	for predec in all_predecs:
		routes[predec] = []
		for desired_var in desired_vars:
			paths = list(nx.all_simple_paths(graph, predec, desired_var))

			for path in paths:
				for var in path:
					if var in desired_vars:  # for each variable in the path, if we find a desired variable we store it and move on
						routes[predec].append(var)
						break

	# turns the routes into sets to avoid duplication
	for key in routes:
		routes[key] = set(routes[key])

	# any vars with only one route to desired variables is either instrumental or precision var
	to_remove = []
	for key in routes:
		if len(routes[key]) <= 1:
			to_remove.append(key)
	for key in to_remove:
		routes = {k: v for k, v in routes.items() if k != key}

	# use the routes dict to add all confounding edges
	for key in routes:
		route = routes[key]
		for var in route:
			reduced_graph.add_edge(key, var)

	# now we can remove some of these edges if they are the first along a path, first we identify these positions
	ordering = {}
	for key in routes:
		route = routes[key]
		ordering[key] = {}
		for var in route:
			for var2 in route:  # count the maximum position of each of the desired vars in each confounded route
				paths = list(nx.all_simple_paths(reduced_graph, var, var2))
				if len(paths) != 0:
					for path in paths:
						for var3 in desired_vars:
							try:
								index = path.index(var3)
								ordering[key][var3] = index
							except:
								pass

	# we now remove the edges to the nodes with zeroth positions in the causal ordering (if they exist at all)
	for key in ordering:
		position_dict = ordering[key]
		for key2 in position_dict:
			if position_dict[key2] == 0:
				try:
					reduced_graph.remove_edge(key, key2)
				except:
					pass

	return reduced_graph
