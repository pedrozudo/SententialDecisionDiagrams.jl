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
            #TODO add test if i>2varcount
        end
        clause = LitSet()
        clause.id = id
        clause.literal_count = length(terms)-1
        clause.op = convert(SddLibrary.BoolOp, 1-op)
        clause.literals = literals
        clause.litset_bit = 0
        push!(litsets, clause)
    end


    fnf = Fnf(var_count, litset_count, litsets, op)
    return fnf
end


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
    node = ONE(manager,fnf.op)
    count = fnf.litset_count
    for i in 1:count
        sort_litsets_by_lca(fnf.litsets[i:end], manager)
        # SddLibrary.sdd_ref(node, manager)

    # println(fnf.litsets[1].vtree)
    end
    #
    # return node


    exit()
end

# SddNode* fnf_to_sdd_auto(Fnf* fnf, SddManager* manager) {
#   SddCompilerOptions* options = sdd_manager_options(manager);
#   int verbose      = options->verbose;
#   BoolOp op        = fnf->op;
#   SddSize count    = fnf->litset_count;
#   LitSet** litsets = (LitSet**) malloc(count*sizeof(LitSet*));
#   for (SddSize i=0; i<count; i++) litsets[i] = fnf->litsets + i;
#
#   if(verbose) { printf("\nclauses: %ld ",count); fflush(stdout); }
#   SddNode* node = ONE(manager,op);
#   for(int i=0; i<count; i++) {
#     sort_litsets_by_lca(litsets+i,count-i,manager);
#     sdd_ref(node,manager);
#     SddNode* l = apply_litset(litsets[i],manager);
#     sdd_deref(node,manager);
#     node = sdd_apply(l,node,op,manager);
#     if(verbose) { printf("%ld ",count-i-1); fflush(stdout); }
#   }
#   free(litsets);
#   return node;
# }


function fnf_to_sdd_manual(fnf::Fnf, manager::Ptr{SddLibrary.SddManager_c}, options)::Ptr{SddLibrary.SddNode_c}
    exit()
end



#
# SddNode* fnf_to_sdd_manual(Fnf* fnf, SddManager* manager) {
#   SddCompilerOptions* options = sdd_manager_options(manager);
#   int verbose      = options->verbose;
#   int period       = options->vtree_search_mode;
#   BoolOp op        = fnf->op;
#   SddSize count    = fnf->litset_count;
#   LitSet** litsets = (LitSet**) malloc(count*sizeof(LitSet*));
#   for (SddSize i=0; i<count; i++) litsets[i] = fnf->litsets + i;
#   sort_litsets_by_lca(litsets,count,manager);
#
#   if(verbose) { printf("\nclauses: %ld ",count); fflush(stdout); }
#   SddNode* node = ONE(manager,op);
#   for(int i=0; i<count; i++) {
#     if(period > 0 && i > 0 && i%period==0) {
#       // after every period clauses
#       sdd_ref(node,manager);
#       if(options->verbose) { printf("* "); fflush(stdout); }
#       sdd_manager_minimize_limited(manager);
#       sdd_deref(node,manager);
#       sort_litsets_by_lca(litsets+i,count-i,manager);
#     }
#
#     SddNode* l = apply_litset(litsets[i],manager);
#     node = sdd_apply(l,node,op,manager);
#     if(verbose) { printf("%ld ",count-i-1); fflush(stdout); }
#   }
#   free(litsets);
#   return node;
# }
#

# //converts a clause/term into an equivalent sdd
# SddNode* apply_litset(LitSet* litset, SddManager* manager) {
#
#   BoolOp op            = litset->op; //conjoin (term) or disjoin (clause)
#   SddLiteral* literals = litset->literals;
#   SddNode* node        = ONE(manager,op); //will not be gc'd
#
#   for(SddLiteral i=0; i<litset->literal_count; i++) {
#     SddNode* literal = sdd_manager_literal(literals[i],manager);
#     node             = sdd_apply(node,literal,op,manager);
#   }
#
#   return node;
# }












# void sort_litsets_by_lca(LitSet** litsets, SddSize size, SddManager* manager) {
#   //compute lcas of litsets
#   for(SddLiteral i=0; i<size; i++) {
#     LitSet* litset = litsets[i];
#     litset->vtree  = sdd_manager_lca_of_literals(litset->literal_count,litset->literals,manager);
#   }
#   //sort
#   qsort((LitSet**)litsets,size,sizeof(LitSet*),litset_cmp_lca);
# }



















# void free_fnf(Fnf* fnf);
#
#
# /****************************************************************************************
#  * forward references
#  ****************************************************************************************/
#
# void sort_litsets_by_lca(LitSet** litsets, SddSize litset_count, SddManager* manager);















function sort_litsets_by_lca(litsets::Array{LitSet}, manager::Ptr{SddLibrary.SddManager_c})

    for ls in litsets
        ls.vtree = SddLibrary.sdd_manager_lca_of_literals(ls.literal_count, ls.literals, manager)

    end

    # return fnf
end






# //first: incomparable lcas are left to right, comparabale lcas are top to down
# //then: shorter to larger litsets
# //last: by id to obtain unique order
# void sort_litsets_by_lca(LitSet** litsets, SddSize size, SddManager* manager) {
#   //compute lcas of litsets
#   for(SddLiteral i=0; i<size; i++) {
#     LitSet* litset = litsets[i];
#     litset->vtree  = sdd_manager_lca_of_literals(litset->literal_count,litset->literals,manager);
#   }
#   //sort
#   qsort((LitSet**)litsets,size,sizeof(LitSet*),litset_cmp_lca);
# }






# int litset_cmp_lca(const void* litset1_loc, const void* litset2_loc) {
#
#   LitSet* litset1 = *(LitSet**)litset1_loc;
#   LitSet* litset2 = *(LitSet**)litset2_loc;
#
#   Vtree* vtree1 = litset1->vtree;
#   Vtree* vtree2 = litset2->vtree;
#   SddLiteral p1 = sdd_vtree_position(vtree1);
#   SddLiteral p2 = sdd_vtree_position(vtree2);
#
#   if(vtree1!=vtree2 && (sdd_vtree_is_sub(vtree2,vtree1) || (!sdd_vtree_is_sub(vtree1,vtree2) && (p1 > p2)))) return 1;
#   else if(vtree1!=vtree2 && (sdd_vtree_is_sub(vtree1,vtree2) || (!sdd_vtree_is_sub(vtree2,vtree1) && (p1 < p2)))) return -1;
#   else {
#
#   SddLiteral l1 = litset1->literal_count;
#   SddLiteral l2 = litset2->literal_count;
#
#   if(l1 > l2) return 1;
#   else if(l1 < l2) return -1;
#   else {
#     //so the litset order is unique
#   	//without this, final litset order may depend on system
#     SddSize id1 = litset1->id;
#     SddSize id2 = litset2->id;
#     if(id1 > id2) return 1;
#     else if(id1 < id2) return -1;
#     else return 0;
#   }
#   }
# }
#
