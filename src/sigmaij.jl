function sigmaij{T}(g::AbstractGraph{T}, κ::Int, ρ::Int)
    kpath = erwkpath(g, κ, ρ)
    proximity = zeros(num_edges(g))
    for e in edges(g)
        v, w = source(e, g), target(e, g)
        Nv = Set(out_neighbors(v, g))
        Nw = Set(out_neighbors(w, g))
        CN = intersect(Nv, Nw)
        NvCN = setdiff(Nv, CN)
        NwCN = setdiff(Nw, CN)
        LNv = length(Nv)
        LNw = length(Nw)
        LCN = length(CN)
        sum1 = 0.0
        sum2 = 0.0
        sum3 = 0.0
        out_v = out_edges(v, g)
        out_w = out_edges(w, g)
        for e1 in out_edges(v, g)
            i = edge_index(e1, g)
            targete1 = target(e1, g)
            if in(targete1, NvCN)
                sum1 += kpath[i]^2
            end
            for e2 in out_edges(w, g)
                j = edge_index(e2, g)
                targete2 = target(e2, g)
                if in(targete2, NwCN)
                    sum2 += kpath[j]^2
                elseif target(e1, g) == target(e2, g)
                    sum3 += (kpath[i] - kpath[j])^2
                end
            end
        end
        if LCN > 0
            if LNv > LCN
                if LNw > LCN
                    proximity[edge_index(e, g)] = sqrt(sum1/(LNv-LCN) + sum2/(LNw-LCN) + sum3/(LCN))
                else
                    proximity[edge_index(e, g)] = sqrt(sum1/(LNv-LCN) + sum3/(LCN))
                end
            else
                if LNw > LCN
                    proximity[edge_index(e, g)] = sqrt(sum2/(LNw-LCN) + sum3/(LCN))
                else
                    proximity[edge_index(e, g)] = sum3/(LCN)
                end
            end
        else
            if LNv > LCN
                if LNw > LCN
                    proximity[edge_index(e, g)] = sqrt(sum1/(LNv-LCN) + sum2/(LNw-LCN))
                else
                    proximity[edge_index(e, g)] = sqrt(sum1/(LNv-LCN))
                end
            else
                if LNw > LCN
                    proximity[edge_index(e, g)] = sqrt(sum2/(LNw-LCN))
                else
                    proximity[edge_index(e, g)] = 0.0
                end
            end
        end
    end
    proximity
end
