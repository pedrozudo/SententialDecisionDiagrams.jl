mutable struct LitSet
    id::SddLibrary.SddSize
    literal_count::SddLibrary.SddLiteral
    literals::Array{SddLibrary.SddLiteral}
    op::SddLibrary.BoolOp
    vtree::SddLibrary.VTree_c
    litset_bit::UInt8
    LitSet() = new()
end
mutable struct Fnf
    var_count::SddLibrary.SddLiteral
    litset_count::SddLibrary.SddSize
    litsets::Array{LitSet}
    op::SddLibrary.BoolOp
end


function read_cnf(filename::String)::Fnf
    return parse_fnf(filename,  convert(SddLibrary.BoolOp,0))
end
function read_dnf(filename::String)::Fnf
    return parse_fnf(filename, convert(SddLibrary.BoolOp,1))
end

function parse_fnf(filename::String, op::SddLibrary.BoolOp)::Fnf
    f = open(filename)
    lines  = readlines(f)
    close(f)

    id::SddLibrary.SddSize = 0
    var_count::SddLibrary.SddLiteral = 0
    litset_count::SddLibrary.SddSize = 0

    n_extra_lines = 0
    for l in lines
        l_split = split(l)
        n_extra_lines += 1
        if l_split[1]=="c"
            continue
        elseif l_split[1]=="p"
            # if op==0 @assert(l_split[2]=="cnf") else @assert(l_split[2]=="dnf") end
            @assert(l_split[2]=="cnf")
            var_count = parse(SddLibrary.SddLiteral, l_split[3])
            litset_count = parse(SddLibrary.SddSize, l_split[4])
            break
        end
    end

    litsets = LitSet[]
    for c in lines[n_extra_lines+1:end]
        id += 1
        literals = SddLibrary.SddLiteral[]
        terms = split(c)
        for t in terms
            if t=="0" break end
            push!(literals, parse(SddLibrary.SddLiteral, t))
        end

        clause = LitSet()
        clause.id = id
        clause.literal_count = length(terms)-1
        clause.op = 1-op
        clause.literals = literals
        clause.litset_bit = 0

        push!(litsets, clause)
    end


    fnf = Fnf(var_count, litset_count, litsets, op)
    return fnf
end






function fnf_to_sdd(fnf::Fnf, manager::Ptr{SddLibrary.SddManager_c})::Ptr{SddLibrary.SddNode_c}

    println(3)
    exit()
end






# void free_fnf(Fnf* fnf);
#
#
# /****************************************************************************************
#  * forward references
#  ****************************************************************************************/
#
# void sort_litsets_by_lca(LitSet** litsets, SddSize litset_count, SddManager* manager);
