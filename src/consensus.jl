function consensus{V}(g::AbstractGraph{V}, m::Vector{Int})
    !is_directed(g) || error("graph must be undirected.")
    @graph_requires g edge_map
    w = zeros(Int, num_edges(g))
    for e in edges(g)
        i = vertex_index(source(e, g), g)
        j = vertex_index(target(e, g), g)
        if m[i] == m[j]
            w[edge_index(e, g)] = 1
        end
    end
    w
end
