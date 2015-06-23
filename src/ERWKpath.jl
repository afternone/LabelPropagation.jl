function erwkpath{T}(g::AbstractGraph{T}, κ::Int, ρ::Int)

    !is_directed(g) || error("graph must be undirected.")
    @graph_requires g edge_map incidence_list vertex_list vertex_map

    V = vertices(g)
    n = num_vertices(g)
    weights = ones(num_edges(g))

    for i=1:ρ
        visited_edges = Set{Edge{T}}()
        v = V[rand(1:n)]
        candidate_edges = out_edges(v, g)
        j = 0
        while j < κ && !isempty(candidate_edges)
            e = candidate_edges[rand(1:length(candidate_edges))]
            push!(visited_edges, e)
            weights[edge_index(e, g)] += 1.0
            w = target(e, g)
            E = out_edges(w, g)
            candidate_edges = collect(setdiff(Set(E), visited_edges))
            j += 1
        end
    end
    weights /= ρ
end


