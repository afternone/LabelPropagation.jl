module LabelPropagation

using Graphs
export label_propagation, modularity, erwkpath, sigmaij, nmi, nvi
include("community_label_propagation.jl")
include("modularity.jl")
include("ERWKpath.jl")
include("sigmaij.jl")
include("nmi.jl")
include("nvi.jl")
end # module
