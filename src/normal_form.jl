# structures
mutable struct LitSet
    id::SddLibrary.SddSize
    literal_count::SddLibrary.SddLiteral
    literals::Array{SddLibrary.SddLiteral}
    op::SddLibrary.BoolOp
    vtree::Ptr{SddLibrary.VTree_c}
    litset_bit::UInt8
    LitSet() = new()
end

mutable struct Fnf
    var_count::SddLibrary.SddLiteral
    litset_count::SddLibrary.SddSize
    litsets::Array{LitSet}
    op::SddLibrary.BoolOp
end


# i/o
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
        literals = Array{SddLibrary.SddLiteral}(undef, 2var_count)
        for i in 1:length(terms)
            if terms[i]== "0" break end
            literals[i] = parse(SddLibrary.SddLiteral,terms[i])
            #TODO add test if i>2varcount raise
        end
        clause = LitSet()
        clause.id = id
        clause.literal_count = length(terms)-1
        clause.op = convert(SddLibrary.BoolOp, 1-op)
        clause.literals = literals
        clause.litset_bit = 0
        push!(litsets, clause)
    end
    return Fnf(var_count, litset_count, litsets, op)
end


# compiling
ONE(M,OP) = (OP==SddLibrary.CONJOIN ? SddLibrary.sdd_manager_false(M) : SddLibrary.sdd_manager_true(M))
ZERO(M,OP) = (OP==SddLibrary.DISJOIN ? SddLibrary.sdd_manager_true(M) : SddLibrary.sdd_manager_false(M))

function fnf_to_sdd(fnf::Fnf, manager::Ptr{SddLibrary.SddManager_c}, options)::Ptr{SddLibrary.SddNode_c}
    # degenarate fnf
    if fnf.litset_count==0 return ONE(manager,fnf.op) end
    for ls in fnf.litsets
        if ls.literal_count==0
            return ZERO(manager,fnf.op)
        end
    end
    # non-degenarate fnf
    if options.vtree_search_mode<0
        SddLibrary.sdd_manager_auto_gc_and_minimize_on(manager)
        return fnf_to_sdd_auto(fnf, manager, options)
    else
        SddLibrary.sdd_manager_auto_gc_and_minimize_off(manager)
        return fnf_to_sdd_manual(fnf, manager, options)
    end
end

function fnf_to_sdd_auto(fnf::Fnf, manager::Ptr{SddLibrary.SddManager_c}, options)::Ptr{SddLibrary.SddNode_c}
    # TODO verbose print stuff
    verbose = options.verbose
    op = fnf.op
    node = ONE(manager,fnf.op)
    count = fnf.litset_count
    litsets = view(fnf.litsets,:)
    for i in 1:count
        #TODO possible without copying?
        litsets[i:count] =  sort_litsets_by_lca(view(litsets,i:count), manager)
        SddLibrary.sdd_ref(node, manager)
        l = apply_litset(litsets[i], manager)
        SddLibrary.sdd_deref(node, manager)
        node = SddLibrary.sdd_apply(l,node,op,manager)
    end
    println(litsets)
    return node
end

function fnf_to_sdd_manual(fnf::Fnf, manager::Ptr{SddLibrary.SddManager_c}, options)::Ptr{SddLibrary.SddNode_c}
    verbose = options.verbose
    period = options.vtree_search_mode
    op = fnf.op
    count = fnf.litset_count
    litsets = view(fnf.litsets,:)
    node = ONE(manager, op)
    for i in 1:count
        if (period>0) && (i>1) && ((i-1)%period==0)
            SddLibrary.sdd_ref(node, manager)
            SddLibrary.sdd_manager_minimize_limited(manager)
            SddLibrary.sdd_deref(node, manager)
            #TODO possible without copying?
            litsets[i:count] = sort_litsets_by_lca(view(litsets,i:count), manager)
        end
        l = apply_litset(litsets[i], manager)
        node = SddLibrary.sdd_apply(l, node, op, manager)
    end
    return node
end

function apply_litset(litset::LitSet, manager::Ptr{SddLibrary.SddManager_c})::Ptr{SddLibrary.SddNode_c}
    op = litset.op
    literals = litset.literals
    node = ONE(manager,op)
    for i in 1:litset.literal_count
        literal = SddLibrary.sdd_manager_literal(literals[i], manager)
        node = SddLibrary.sdd_apply(node, literal, op, manager)
    end
    return node
end


# sorting
function sort_litsets_by_lca(litsets::SubArray{LitSet}, manager::Ptr{SddLibrary.SddManager_c})::Array{LitSet}
    for ls in litsets
        ls.vtree = SddLibrary.sdd_manager_lca_of_literals(ls.literal_count, ls.literals, manager)
    end
    return sort(litsets)
end

function Base.isless(litset1::LitSet, litset2::LitSet)::Bool
    vtree1 = litset1.vtree
    vtree2 = litset2.vtree

    p1 = SddLibrary.sdd_vtree_position(vtree1)
    p2 = SddLibrary.sdd_vtree_position(vtree2)

    sub12 = convert(Bool, SddLibrary.sdd_vtree_is_sub(vtree1,vtree2))
    sub21 = convert(Bool, SddLibrary.sdd_vtree_is_sub(vtree2,vtree1))

    if ((vtree1!=vtree2) && (sub21 || (!sub12 && (p1>p2)))) return true
    elseif ((vtree1!=vtree2) && (sub12 || (!sub21 && (p1<p2)))) return false
    else
        l1 = litset1.literal_count
        l2 = litset2.literal_count
        if l1>l2 return true
        elseif l1<l2 return false
        else
            id1 = litset.id
            id2 = litset.id
            if id1>id2 return true
            elseif id1<id2 return false
            else return false
            end
        end
    end
end
