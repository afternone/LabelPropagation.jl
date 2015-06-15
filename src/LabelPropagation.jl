module LabelPropagation

using Graphs
export label_propagation, modularity
include("community_label_propagation.jl")
include("modularity.jl")

end # module
