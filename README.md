# minSEM
Graph reduction experiment code and reduction function, accompanying code for 'Prespecification of Structure for Optimizing Data Collection and Research Transparency by Leveraging Conditional Independencies'

```simulations.R``` runs simulations over 5 different full graphs (based on the five graphs explained in the paper).

```reducer.py``` Takes in a networkx DiGraph() object and reduces it to its 'essential' form for Structural Equation Modeling.

```results_vis.ipnyb``` provides the code for analysing the simulation .csv files from simulations.R


Example Usage:
```python
import networkx as nx
from reducer import*

g = nx.DiGraph()
g.add_edge('t', 'y')
g.add_edge('c', 'y')
g.add_edge('c', 't')
xs =['t']
ys = ['y']

rg = reducer(g, xs, ys, remove_precision=True, project_confs=True, project_causes=True)
```

Note:
- The function assumes interest in mediating processes (and so keeps all causal paths).
- The function removes variables which might be useful for precision purposes (thus prioritising reduction in graph complexity over estimation).
- There are a number of worked examples in the reducer.ipynb file.
- The code has not been optimized and has only been tested on graphs with fewer than 10 nodes. 


![](https://github.com/matthewvowels1/minSEM/blob/main/minsem_dem.png)

### Algorithm

For each node in the causal chain, we check its parents and see if these parents are (a) non-causal parents, and (b) connected to any downstream causes. If they are, they are confounders.
For the SEM graph, we therefore need to keep the confounder in the graph, but don't need to estimate the path which was used to identify it as a parent, and so this path is removed.
We then proceed to descend through the causal ordering, finding confounders along the way.

In a bit more detail, the algorithm in ```reducer.py``` follows roughly these steps:

For graph 'G', cause nodes 'xs', and effect nodes 'ys':
1. Topologically order the nodes in G
2. Remove nodes <after> last 'y' in ys in the ordering
3. Get list of all causally relevant vars 'CR' by finding all descendents of xs
4. Get list of non-causal nodes NCR by subtracting the list of all remaining nodes 'AN' in G from all causally relevant vars
5. if 'project_causes' == True, then for each ordered node 'c' in CR,
   1. check if child of c 'cc' has other parents [else next node]
   2. check cc not in xs or ys [else next node]
   3. list cc's children and connect c to them
   4. delete cc from graph
6. For each x in xs, 
   1. Get children xc and parents pc (potential confounder). For each pc, check if in CR, if so, not a confounder
   2. Check if any descendents of pc are in CR [else next x]
   3. Check if we have identified pc before, <as a parent of children on the path from x>. It might have been identified as a confounder for a different var in CR, but this is not sufficient to rule it out.
   4. Remove edge from pc to x
7. if <NOT> project_causes, then Repeat 6. but for one progression lower through the causal ordering (it keeps track of the tree of children that branches from each x in xs) [else skip to 8.]
8. For each remaining node in RN which are <not> in list of verified confounders and <not> in list of other non-causal nodes:
   1. check if ancestors of remaining nodes are in the list of all confounders [if yes, move to next remaining node]
   2. check if remaining node not in xs or ys [else move to next remaining node]
   3. if remove_precision then remove node, else just pass precisions to output of function
9. if 'project_confs' we try to project confounding paths. 
   1. For each confounder in the list of confounders, get descendents and check if, for each remaining node in RN:
   2. check if rn is in list of confounder descendents [else move on to next rn in RN]
   3. get list of remaining nodes parents and remove from this set the confounder of interest
   4. if the number of parents in this list is 0, then the only parent was the original confounder
   5. connect confounders edges to the children of the remaining node
   6. delete the remaining node
10. Repeat step 5 'project causes' again now that any superfluous confounding paths have been removed
11. Removed isolated (completely disconnected) nodes from graph.
12. Return reduced graph, set of confounders, and set of precision variables