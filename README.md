# Finding communities based on propagating labels

## Description
This is a fast, nearly linear time algorithm for detecting communtiy structure in networks. In works by labeling the vertices with unique labels and then updating the labels by majority voting in the neighborhood of the vertex.

## Install
`julia> Pkg.clone("git://github.com/afternone/LabelPropagation.jl.git")`

## Usage
`label_propagation(graph, weights = Float64[], initial = Int[], fixed = Int[])`

### Arguments
* `graph` The input graph, should be undirected to make sense.
* `weights` An optional weight vector. It should contain a positive weight for all the edges. The ‘weight’ edge attribute is used if present.
* `initial` The initial state. If empty, every vertex will have a different label at the beginning. Otherwise it must be a vector with an entry for each vertex. Positive values denote different labels, non-positive entries denote vertices without labels.
`fixed` Logical vector denoting which labels are fixed. Of course this makes sense only if you provided an initial state, otherwise this element will be ignored. Also note that vertices without labels cannot be fixed.

## Details
This function implements the community detection method described in: Raghavan, U.N. and Albert, R. and Kumara, S.: Near linear time algorithm to detect community structures in large-scale networks. Phys Rev E 76, 036106. (2007). This version extends the original method by the ability to take edge weights into consideration and also by allowing some labels to be fixed.

From the abstract of the paper: “In our algorithm every node is initialized with a unique label and at every step each node adopts the label that most of its neighbors currently have. In this iterative process densely connected groups of nodes form a consensus on a unique label to form communities.”

## Return Value
label_propagation returns a membership vector with labels for each vertex.

## References
Raghavan, U.N. and Albert, R. and Kumara, S.: [Near linear time algorithm to detect community structures in large-scale networks](http://journals.aps.org/pre/abstract/10.1103/PhysRevE.76.036106). Phys Rev E 76, 036106. (2007)

## Examples
```
using Graphs
using LabelPorpagation

es = readdlm("data/karate.txt", Int) # read edges from file
g = simple_graph(maximum(es), is_directed=false)
for i=1:size(es,1)
	add_edge!(g, es[i,1], es[i,2])
end
membership = label_propagation(g)
modularity_value = modularity(g, membership)
```

[![Build Status](https://travis-ci.org/afternone/LabelPropagation.jl.svg?branch=master)](https://travis-ci.org/afternone/LabelPropagation.jl)
