# minSEM
Graph reduction experiment code and reduction function, accompanying code for 'Prespecification of Structure for Optimizing Data Collection and Research Transparency by Leveraging Conditional Independencies'

```simulations.R``` runs simulations over 5 different full graphs (based on the five graphs explained in the paper).

```reducer.py``` Takes in a networkx DiGraph() object and reduces it to its 'essential' form for Structural Equation Modeling.

```results_vis.ipnyb``` provides the code for analysing the simulation .csv files from simulations.R

Note:
- The function assumes interest in mediating processes (and so keeps all causal paths).
- The function removes variables which might be useful for precision purposes (thus prioritising reduction in graph complexity over estimation).
s There are two worked examples in the reducer.ipynb file.
- The code has not been optimized and has only been tested on graphs with fewer than 10 nodes. It is exponential in running time (pending later update) and may therefore take a prohibitively long time to run on larger graphs.