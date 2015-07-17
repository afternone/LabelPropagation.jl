function label_propagation{V,T<:Real}(graph::AbstractGraph{V};
                                      weights::Vector{T} = Array(Float64, 0),
                                      proximity::Vector{T} = Array(Float64, 0),
                                      initial::Dict{V,Int} = Dict{V,Int}(),
                                      fixed::Set{V} = Set{V}())
    !is_directed(graph) || error("graph must be undirected.")
    if !isempty(proximity)
        @graph_requires graph edge_map incidence_list
        if length(proximity) != num_edges(graph)
            error("Invalid proximity vector length")
        elseif minimum(proximity) < 0 || maximum(proximity) > 1
            error("Proximity must between 0 and 1")
        end
        mix_label_propagation!(graph, _init(graph, initial, fixed)..., proximity)
    else
        if !isempty(weights)
            @graph_requires graph edge_map incidence_list
            if length(weights) != num_edges(graph)
                error("Invalid weight vector length")
            elseif minimum(weights) < 0
                error("Weights must be non-negative")
            end
            label_propagation!(graph, _init(graph, initial, fixed)..., weights)
        else
            label_propagation!(graph, _init(graph, initial, fixed)...)
        end
    end
end

function _init{V}(graph::AbstractGraph{V},
                  initial::Dict{V,Int} = Dict{V,Int}(), # initial vertex label map
                  fixed::Set{V} = Set{V}())             # initial label fixed nodes

    @graph_requires graph vertex_list vertex_map

    N = num_vertices(graph)
    membership = zeros(Int, N)
    unfixed = V[]

    # Do some initial checks
    if !isempty(fixed) && isempty(initial)
        warn("Ignoring fixed vertices as no initial labeling given")
    end

    if !isempty(initial)
        for v in vertices(graph)
            v_idx = vertex_index(v, graph)
            if haskey(initial, v)
                membership[v_idx] = initial[v]
            else
                membership[v_idx] = 0
            end
        end

        for v in vertices(graph)
            if in(v, fixed)
                if membership[vertex_index(v, graph)] < 1
                    warn("Fixed nodes cannot be unlabeled, ignoring them")
                    push!(unfixed, v)
                end
            else
                push!(unfixed, v)
            end
        end

        i = maximum(membership)
        i <= N || error("elements of the initial labeling vector must be between 1 and |V|")
        i > 0 || error("at least one vertex must be labeled in the initial labeling")
    else
        membership = [1:N]
        unfixed = collect(vertices(graph))
    end

    membership, unfixed
end

function label_propagation!{V,T<:Real}(graph::AbstractGraph{V},
                                       membership::Vector{Int},
                                       unfixed::Vector{V},
                                       weights::Vector{T})

    @graph_requires graph vertex_map edge_map incidence_list

    label_counters = zeros(T, num_vertices(graph))

    running = true
    while running
        running = false

        # Shuffle the node ordering vector
        X = shuffle(unfixed)

        # In the prescribed order, loop over the vertices and reassign labels
        for v in X
            v_idx = vertex_index(v, graph)

            # Clear dominant_labels and nonzero_labels
            dominant_labels = Int[]
            nonzero_labels = Int[]

            # recount
            max_count = zero(T)

            for e in out_edges(v, graph)
                k = membership[vertex_index(target(e, graph), graph)]

                # skip if it has no label yet
                k != 0 || continue

                was_zero = label_counters[k] == zero(T)
                label_counters[k] += weights[edge_index(e, graph)]
                if was_zero && label_counters[k] != zero(T)
                    # counter just became nonzero
                    push!(nonzero_labels, k)
                end
                if max_count < label_counters[k]
                    max_count = label_counters[k]
                    resize!(dominant_labels, 1)
                    dominant_labels[1] = k
                elseif max_count == label_counters[k]
                    push!(dominant_labels, k)
                end
            end

            if !isempty(dominant_labels)

                # Select randomly from the dominant labels
                k = dominant_labels[rand(1:length(dominant_labels))]

                # Check if the current label of the node is also dominant
                if label_counters[membership[v_idx]] != max_count
                    # Nope, we need at least one more iteration
                    running = true
                end

                # Update label of the current node
                membership[v_idx] = k
            end
            # Clear the nonzero elements in label_counters
            for i in nonzero_labels
                label_counters[i] = zero(T)
            end
        end
    end
    permute_labels!(membership)
    membership
end

function label_propagation!{V}(graph::AbstractGraph{V},
                               membership::Vector{Int},
                               unfixed::Vector{V})

    @graph_requires graph vertex_map adjacency_list

    label_counters = zeros(Int, num_vertices(graph))

    running = true
    while running
        running = false

        # Shuffle the node ordering vector
        X = shuffle(unfixed)

        # In the prescribed order, loop over the vertices and reassign labels
        for u in X
            u_idx = vertex_index(u, graph)

            # Clear dominant_labels and nonzero_labels
            dominant_labels = Int[]
            nonzero_labels = Int[]

            # recount
            max_count = 0

            for v in out_neighbors(u, graph)
                k = membership[vertex_index(v, graph)]

                # skip if it has no label yet
                k != 0 || continue

                label_counters[k] += 1

                # counter just became nonzero
                label_counters[k] != 1 || push!(nonzero_labels, k)

                if max_count < label_counters[k]
                    max_count = label_counters[k]
                    resize!(dominant_labels, 1)
                    dominant_labels[1] = k
                elseif max_count == label_counters[k]
                    push!(dominant_labels, k)
                end
            end

            if !isempty(dominant_labels)

                # Select randomly from the dominant labels
                k = dominant_labels[rand(1:length(dominant_labels))]

                # Check if the current label of the node is also dominant
                if label_counters[membership[u_idx]] != max_count
                    # Nope, we need at least one more iteration
                    running = true
                end

                # Update label of the current node
                membership[u_idx] = k
            end
            # Clear the nonzero elements in label_counters
            for i in nonzero_labels
                label_counters[i] = 0
            end
        end
    end
    permute_labels!(membership)
    membership
end

function mix_label_propagation!{V,T<:Real}(graph::AbstractGraph{V},
                                           membership::Vector{Int},
                                           unfixed::Vector{V},
                                           proximity::Vector{T})
    @graph_requires graph edge_map incidence_list vertex_map

    N = num_vertices(graph)
    label_counters = zeros(T, N)
    proximity_sum = zeros(T, N)
    similarity = Array(T, 0)

    running = true
    while running
        running = false

        # Shuffle the node ordering vector
        X = shuffle(unfixed)

        # In the prescribed order, loop over the vertices and reassign labels
        for v in X
            v_idx = vertex_index(v, graph)

            # Clear dominant_labels and nonzero_labels
            dominant_labels = Int[]
            nonzero_labels = Int[]

            # recount
            max_count = zero(T)

            for e in out_edges(v, graph)
                e_idx = edge_index(e, graph)
                k = membership[vertex_index(target(e, graph), graph)]

                # skip if it has no label yet
                k != 0 || continue

                was_zero = label_counters[k] == zero(T)
                label_counters[k] += 1
                proximity_sum[k] += proximity[e_idx]
                if was_zero && label_counters[k] != zero(T)
                    # counter just became nonzero
                    push!(nonzero_labels, k)
                end
                if max_count < label_counters[k]
                    max_count = label_counters[k]
                    resize!(dominant_labels, 1)
                    resize!(similarity, 1)
                    dominant_labels[1] = k
                    similarity[1] = proximity_sum[k]
                elseif max_count == label_counters[k]
                    push!(dominant_labels, k)
                    push!(similarity, proximity_sum[k])
                end
            end

            if !isempty(dominant_labels)

                max_similarity = maximum(similarity)
                candidate_labels = dominant_labels[similarity.>=max_similarity]

                # Select randomly from the dominant labels

                k = candidate_labels[rand(1:length(candidate_labels))]

                # Check if the current label of the node is also dominant
                if label_counters[membership[v_idx]] != max_count
                    # Nope, we need at least one more iteration
                    running = true
                end

                # Update label of the current node
                membership[v_idx] = k
            end
            # Clear the nonzero elements in label_counters
            for i in nonzero_labels
                label_counters[i] = zero(T)
                proximity_sum[i] = zero(T)
            end
        end
    end
    permute_labels!(membership)
    membership
end

function permute_labels!(membership::Vector{Int})
    N = length(membership)
    if maximum(membership) > N || minimum(membership) < 1
        error("Label must between 1 and |V|")
    end
    label_counters = zeros(Int, N)
    j = 1
    for i=1:length(membership)
        k = membership[i]
        if k >= 1
            if label_counters[k] == 0
                # We have seen this label for the first time
                label_counters[k] = j
                k = j
                j += 1
            else
                k = label_counters[k]
            end
        end
        membership[i] = k
    end
end
