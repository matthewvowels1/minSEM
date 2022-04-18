# minSEM
Graph reduction experiment code and reduction function, accompanying code for 'Maximizing Statistical Power in Path and Structural Equation Models by Leveraging Conditional Independencies'

```simulations.R``` runs simulations over 5 different full graphs (based on the five graphs explained in the paper).

```reducer.py``` Takes in a networkx DiGraph() object and reduces it to its 'essential' form for Structural Equation Modeling.

Note:
The function assumes interest in mediating processes (and so keeps all causal paths).
The function removes variables which might be useful for precision purposes (thus prioritising reduction in graph complexity over estimation).
s There are two worked examples in the reducer.ipynb file.