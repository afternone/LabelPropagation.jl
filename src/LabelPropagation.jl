module LabelPropagation

using Graphs
export label_propagation, modularity, erwkpath, sigmaij, nmi, nvi, consensus, rankedge, rankedge1, nei_label_propagation, rankedgebynei
include("community_label_propagation.jl")
include("modularity.jl")
include("ERWKpath.jl")
include("sigmaij.jl")
include("nmi.jl")
include("nvi.jl")
include("consensus.jl")
include("rankedge.jl")
end # module
