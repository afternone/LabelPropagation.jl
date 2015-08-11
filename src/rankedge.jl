function rankedge{V}(graph::AbstractGraph{V})
    weights = zeros(num_edges(graph))
    for e in edges(graph)
        e_idx = edge_index(e, graph)
        u = source(e, graph)
        v = target(e, graph)
        u_neighbors = Set{V}(out_neighbors(u, graph))
        v_neighbors = Set{V}(out_neighbors(v, graph))
        common_neighbors = intersect(u_neighbors, v_neighbors)
        union_neighbors = union(u_neighbors, v_neighbors)
        union_neighbors = setdiff(union_neighbors, Set{V}({u,v}))
        no_common_neighbors = setdiff(union_neighbors, common_neighbors)
        weights[e_idx] = (length(common_neighbors) + 1) / (length(no_common_neighbors) + 1)
    end
    weights
end

function rankedge1{V}(graph::AbstractGraph{V})
    weights = zeros(num_edges(graph))
    for e in edges(graph)
        e_idx = edge_index(e, graph)
        u = source(e, graph)
        v = target(e, graph)
        u_neighbors = Set{V}(out_neighbors(u, graph))
        v_neighbors = Set{V}(out_neighbors(v, graph))
        common_neighbors = intersect(u_neighbors, v_neighbors)
        union_neighbors = union(u_neighbors, v_neighbors)
        union_neighbors = setdiff(union_neighbors, Set{V}({u,v}))
        no_common_neighbors = setdiff(union_neighbors, common_neighbors)
        weights[e_idx] = (length(common_neighbors) + 1) / (length(no_common_neighbors) + length(common_neighbors) + 1)
    end
    weights
end

function rankedgenocommon{V}(graph::AbstractGraph{V})
    weights = zeros(num_edges(graph))
    for e in edges(graph)
        e_idx = edge_index(e, graph)
        u = source(e, graph)
        v = target(e, graph)
        u_neighbors = Set{V}(out_neighbors(u, graph))
        v_neighbors = Set{V}(out_neighbors(v, graph))
        common_neighbors = intersect(u_neighbors, v_neighbors)
        union_neighbors = union(u_neighbors, v_neighbors)
        union_neighbors = setdiff(union_neighbors, Set{V}({u,v}))
        no_common_neighbors = setdiff(union_neighbors, common_neighbors)
        weights[e_idx] = length(no_common_neighbors)
    end
    weights
end

function rankedgebynei{V}(graph::AbstractGraph{V})
    weights = zeros(num_edges(graph))
    for e in edges(graph)
        e_idx = edge_index(e, graph)
        u = source(e, graph)
        v = target(e, graph)
        u_neighbors = Set{V}(out_neighbors(u, graph))
        v_neighbors = Set{V}(out_neighbors(v, graph))
        common_neighbors = intersect(u_neighbors, v_neighbors)
        weights[e_idx] = length(common_neighbors)
    end
    weights
end
