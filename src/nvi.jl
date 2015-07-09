# calculate the normalised mutual information measure
function nvi(ca::Vector{Int}, cb::Vector{Int})
    length(ca) == length(cb) || error("membership length must be equal")
    n_ca = maximum(ca)
    n_cb = maximum(cb)
    ca_set = Set{Int}[]
    cb_set = Set{Int}[]
    for i=1:n_ca
        push!(ca_set, Set{Int}())
    end
    for (u, i) in enumerate(ca)
        push!(ca_set[i], u)
    end
    for j=1:n_cb
        push!(cb_set, Set{Int}())
    end
    for (v, j) in enumerate(cb)
        push!(cb_set[j], v)
    end
    N = zeros(Int, n_ca, n_cb) # confusion matrix
    for i=1:n_ca, j=1:n_cb
        N[i,j] = length(intersect(ca_set[i], cb_set[j]))
    end
    N1 = collect(sum(N, 1))
    N2 = collect(sum(N, 2))
    Nsum = length(ca)
    VI = 0.0
    for i=1:n_ca, j=1:n_cb
        if N[i,j]>0
            VI += N[i,j]*(log(N2[i]/N[i,j]) + log(N1[j]/N[i,j]))/Nsum
        end
    end
    VI/log(Nsum)
end
