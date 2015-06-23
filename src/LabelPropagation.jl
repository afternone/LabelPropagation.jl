module LabelPropagation

using Graphs
export label_propagation, modularity, erwkpath
include("community_label_propagation.jl")
include("modularity.jl")
include("ERWKpath.jl")
end # module
