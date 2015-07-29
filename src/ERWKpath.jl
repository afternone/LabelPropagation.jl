function erwkpath{T}(g::AbstractGraph{T}, κ::Int, ρ::Int)

    @graph_requires g edge_map incidence_list vertex_list vertex_map

    V = vertices(g)
    N = num_vertices(g)
    weights = ones(num_edges(g))

    for i=1:ρ
        visited_edges = Set{Edge{T}}()
        v = V[rand(1:N)]
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

function erwkpath1{T}(g::AbstractGraph{T}, κ::Int, ρ::Int)

    @graph_requires g edge_map incidence_list vertex_list vertex_map

    V = vertices(g)
    N = num_vertices(g)
    weights = ones(num_edges(g))

    for i=1:ρ
        visited_edges = Set{Int}()
        u = V[rand(1:N)]
        candidate_edges = Int[edge_index(e, g) for e in out_edges(u, g)]
        j = 0
        while j < κ && !isempty(candidate_edges)
            em_idx = candidate_edges[rand(1:length(candidate_edges))]
            v = target(edges(g)[em_idx], g)
            weights[em_idx] += 1
            push!(visited_edges, em_idx)
            E = Int[edge_index(e, g) for e in out_edges(v, g)]
            candidate_edges = collect(setdiff(Set(E), visited_edges))
            j += 1
        end
    end
    weights /= (ρ+1)
end
