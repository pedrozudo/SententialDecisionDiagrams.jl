#TODO add bangs for functions that modify argument(s)
module SententialDecisionDiagrams

using Parameters

include("sddapi.jl")
include("fnf.jl")

using .SddLibrary


struct VTree
    vtree::Ptr{SddLibrary.VTree_c}
end

struct SddManager
    manager::Ptr{SddLibrary.SddManager_c}
end

struct SddNode
    node::Ptr{SddLibrary.SddNode_c}
    manager::Ptr{SddLibrary.SddManager_c}
end

struct PrimeSub
    prime::SddNode
    sub::SddNode
end

struct WmcManager
    manager::Ptr{SddLibrary.WmcManager_c}
end

function str_to_char(vtree_type::String)::Ptr{UInt8}
    return pointer(vtree_type)
end

# SDD MANAGER FUNCTIONS
function sdd_manager(vtree::VTree)::SddManager
    manager = SddLibrary.sdd_manager_new(vtree.vtree)
    return SddManager(manager)
end
function sdd_manager(var_count::Integer,  auto_gc_and_minimize::Bool)::SddManager
    manager = SddLibrary.sdd_manager_create(convert(SddLibrary.SddLiteral, var_count), auto_gc_and_minimize)
    return SddManager(manager)
end
# TODO function manager_new
function free(manager::SddManager)
    SddLibrary.sdd_manager_free(manager.manager)
end
function Base.print(manager::SddManager)
    SddLibrary.sdd_manager_print(manager.manager)
end
function auto_gc_and_minimize_on(manager::SddManager)
    SddLibrary.sdd_manager_auto_gc_and_minimize_on(manager.manager)
end
function sdd_manager_auto_gc_and_minimize_off(manager::SddManager)
    SddLibrary.sdd_manager_auto_gc_and_minimize_off(manager.manager)
end
function is_auto_gc_and_minimize_on(manager::SddManager)::Bool
    return convert(Bool, SddLibrary.sdd_manager_is_auto_gc_and_minimize_on(manager.manager))
end
# TODO void sdd_manager_set_minimize_function
function unset_minimize_function(manager::SddManager)
    SddLI.sdd_manager_unset_minimize_function(manager.manager)
end
function options(manager::SddManager)
    SddLI.sdd_manager_options(manager.manager)
end
# TODO void sdd_manager_set_options(void* options, SddManager* manager);
function is_var_used(var::Integer, manager::SddManager)::Bool
    return convert(Bool, SddLibrary.sdd_manager_is_var_used(convert(SddLibrary.SddLiteral, var),manager.manager))
end
function vtree_of_var(var::Integer, manager::SddManager)::VTree
    vtree = SddLibrary.sdd_manager_vtree_of_var(convert(SddLibrary.SddLiteral, var), manager.manager)
    return VTree(vtree)
end
# TODO Vtree* sdd_manager_lca_of_literals(int count, SddLiteral* literals, SddManager* manager);
function var_count(manager::SddManager)::SddLibrary.SddLiteral
    return SddLibrary.sdd_manager_var_count(manager.manager)
end
# TODO void sdd_manager_var_order(SddLiteral* var_order, SddManager *manager);
function add_var_before_first(manager::SddManager)
    SddLibrary.sdd_manager_add_var_before_first(manager.manager)
end
function add_var_after_last(manager::SddManager)
    SddLibrary.sdd_manager_add_var_after_last(manager.manager)
end
function add_var_before(manager::SddManager)
    SddLibrary.sdd_manager_add_var_before(manager.manager)
end
function add_var_after(manager::SddManager)
    SddLibrary.sdd_manager_add_var_after(manager.manager)
end

# TERMINAL SDDS
function literal(tf::Bool, manager::SddManager)::SddNode
    if tf
        node = SddLibrary.sdd_manager_false(manager.manager)
    elseif  !tf
        node = SddLibrary.sdd_manager_true(manager.manager)
    end
    return SddNode(node, manager.manager)
end
function literal(literal::Integer, manager::SddManager)::SddNode
    node = SddLibrary.sdd_manager_literal(convert(SddLibrary.SddLiteral, literal), manager.manager)
    return SddNode(node, manager.manager)
end

# SDD QUERIES AND TRANSFORMATIONS
function apply(node1::SddNode, node2::SddNode, op::Bool, manager::SddManager)::SddNode
    node = SddLibrary.sdd_apply(node1.node, node2.node, convert(SddLibrary.SddBoolOp, op), manager.manager)
    return SddNode(node, node1.manager)
end
function conjoin(node1::SddNode, node2::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_conjoin(node1.node, node2.node, manager.manager)
    return SddNode(node, manager.manager)
end
function disjoin(node1::SddNode, node2::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_disjoin(node1.node, node2.node, manager.manager)
    return SddNode(node, manager.manager)
end
function negate(node::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_negate(node.node, node.manager)
    return SddNode(node, manager.manager)
end
function condition(lit::Integer, node::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_condition(convert(SddLibrary.SddLiteral,lit), node.node, manager.manager)
    return SddNode(node, manager.manager)
end
function exists(lit::Integer, node::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_exists(convert(SddLibrary.SddLiteral,lit), node.node, manager.manager)
    return SddNode(node, manager.manager)
end
function exists_multiple(exists_map::Array{Integer,1}, node::SddNode, manager::SddManager; static::Bool=false)::SddNode
    if  !static
        node = SddLibrary.sdd_exists(convert(Array{Cint,1},exists_map), node.node, manager.manager)
    else
        node = SddLibrary.sdd_exists_multiple_static(convert(Array{Cint,1},exists_map), node.node, manager.manager)
    end
    return SddNode(node, manager.manager)
end
function for_all(lit::Integer, node::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_forall(convert(SddLibrary.SddLiteral,lit), node.node, manager.manager)
    return SddNode(node, manager.manager)
end
function minimize_cardinality(node::SddNode, manager::SddManager; globally::Bool=false)::SddNode
    if  !globally
        node = SddLibrary.sdd_minimize_cardinality(node.node, manager.manager)
    else
        node = SddLibrary.sdd_global_minimize_cardinality(node.node, manager.manager)
    end
    return SddNode(node, manager.manager)
end
function minimum_cardinality(node::SddNode)::SddLibrary.SddLiteral
    return SddLibrary.sdd_minimum_cardinality(node.node)
end
function model_count(node::SddNode, manager::SddManager; globally::Bool=false)::SddLibrary.SddModelCount
    if !globally
        return SddLibrary.sdd_model_count(node.node, manager.manager)
    else
        return SddLibrary.sdd_global_model_count(node.node, manager.manager)
    end
end

# SDD NAVIGATION
function is_true(node::SddNode)::Bool
    res = SddLibrary.sdd_node_is_true(node.node)
    return convert(Bool, res)
end
function is_false(node::SddNode)::Bool
    res = SddLibrary.sdd_node_is_false(node.node)
    return convert(Bool, res)
end
function is_literal(node::SddNode)::Bool
    res = SddLibrary.sdd_node_is_literal(node.node)
    return convert(Bool, res)
end
function is_decision(node::SddNode)::Bool
    res = SddLibrary.sdd_node_is_decision(node.node)
    return convert(Bool, res)
end
function node_size(node::SddNode)::SddLibrary.SddNodeSize
    return SddLibrary.sdd_node_size(node.node)
end
function literal(node::SddNode)::SddLibrary.SddLiteral
    return SddLibrary.sdd_node_literal(node.node)
end
function elements(node::SddNode)::Array{PrimeSub,1}
    # TODO make abstract array for primesubs and avoid copying
    elements_ptr = SddLibrary.sdd_node_elements(node.node)
    m = size(node)
    primesubs = PrimeSub[]
    for i in 0:m-1
        e = unsafe_load(elements_ptr+i)
        p = SddNodde(e, node.manager)
        s = SddNode(e+1, node.manager)
        push!(primesubs, PrimeSub(p, s))
    end
    return primesubs
end
function set_bit(bit::Int32, node::SddNode)
    SddLibrary.sdd_node_set_bit(bit, node.node)
end
function bit(node::SddNode)::Int32
    return SddLibrary.sdd_node_bit(node.node)
end


#
# # SDD FUNCTIONS

# SDD FILE I/O
# TODO make this safer
function read_sdd(filename::String, manager::SddManager)::SddNode
    node = SddLibrary.sdd_read(str_to_char(filename), manager.manager)
    return SddNode(node, manager.manager)
end
function save(filename::String, node::SddNode)
    SddLibrary.sdd_save(str_to_char(filename), node.node)
end
function save_as_dot(filename::String, node::SddNode)
    SddLibrary.sdd_save_as_dot(str_to_char(filename), node.node)
end
function shared_save_as_dot(filename::String, manager::SddManager)
    SddLibrary.sdd_shared_save_as_dot(str_to_char(filename), manager.manager)
end

# SDD SIZE AND NODE COUNT
# SDD
function count(node::SddNode)::SddLibrary.SddSize
    return SddLibrary.sdd_count(node.node)
end
function size(node::SddNode)::SddLibrary.SddSize
    return SddLibrary.sdd_size(node.node)
end
# SDD OF MANAGER
manager_size_fnames_c = [
    "size", "live_size", "dead_size",
    "count", "live_count", "dead_count"
]
for (fnj,fnc) in zip(manager_size_fnames_c, SddLibrary.manager_size_fnames_c)
    @eval begin
        function $(Symbol(fnj))(manager::SddManager)::SddLibrary.SddSize
            return ((SddLibrary).$(Symbol(fnc)))(manager.manager)
        end
    end
end
# SDD SIZE OF VTREE
vtree_size_fnames_j = [
    "size", "live_size", "dead_size",
    "size_at", "live_size_at", "dead_size_at",
    "size_above", "live_size_above", "dead_size_above",
    "count", "live_count", "dead_count",
    "count_at", "live_count_at", "dead_count_at",
    "count_above", "live_count_above", "dead_count_above"
]
for (fnj,fnc) in zip(vtree_size_fnames_j, SddLibrary.vtree_size_fnames_c)
    @eval begin
        function $(Symbol(fnj))(vtree::VTree)::SddLibrary.SddSize
            return ((SddLibrary).$(Symbol(fnc)))(vtree.vtree)
        end
    end
end

# CREATING VTREES
function vtree(var_count::Integer, vtree_type::String)::VTree
    vtree = SddLibrary.sdd_vtree_new(convert(SddLibrary.SddLiteral,var_count), str_to_char(vtree_type))
    return VTree(vtree)
end
function vtree(var_count::Integer, order::Array{<:Integer,1}, vtree_type::String; order_type::String="var_order")::VTree
    @assert order_type in Set(["var_order", "is_X_var"]) "$order_type not in a valid order type (var_order, is_X_var]"
    if order_type=="var_order"
        vtree = SddLibrary.sdd_vtree_new_with_var_order(convert(SddLibrary.SddLiteral,var_count), convert(Array{SddLibrary.SddLiteral,1},order), str_to_char(vtree_type))
    elseif order_type=="is_X_var"
        vtree = SddLibrary.sdd_vtree_new_X_constrained(convert(SddLibrary.SddLiteral,var_count), convert(Array{SddLibrary.SddLiteral,1},order), str_to_char(vtree_type))
    end
    return VTree(vtree)
end
function free(vtree::VTree)
    SddLibrary.sdd_vtree_free(vtree.vtree)
end

# VTREE FILE I/O
# TODO make this safer
function read_vtree(filename::String)::VTree
    vtree = SddLibrary.sdd_vtree_read(str_to_char(filename))
    return VTree(vtree)
end
function save(filename::String, vtree::VTree)
    SddLibrary.sdd_vtree_save(str_to_char(filename), vtree.vtree)
end
function save_as_dot(filename::String, vtree::VTree)
    SddLibrary.sdd_vtree_save_as_dot(str_to_char(filename), vtree.vtree)
end

# SDD MANAGER VTREE
function vtree(manager::SddManager; copy::Bool=false)::VTree
    if !copy
        vtree = SddLibrary.sdd_manager_vtree(manager.manager)
        return VTree(vtree)
    else
        vtree = SddLibrary.sdd_manager_vtree_copy(manager.manager)
        return VTree(vtree)
    end
end

# VTREE NAVIGATION
function left(vtree::VTree)::VTree
    vtree = SddLibrary.sdd_vtree_left(vtree.vtree)
    return VTree(vtree)
end
function right(vtree::VTree)::VTree
    vtree = SddLibrary.sdd_vtree_right(vtree.vtree)
    return VTree(vtree)
end
function parent(vtree::VTree)::VTree
    vtree = SddLibrary.sdd_vtree_parent(vtree.vtree)
    return VTree(vtree)
end

# VTREE FUNCTIONS
function is_leaf(vtree::VTree)::Bool
    return convert(Bool, SddLibrary.sdd_vtree_is_leaf(vtree.vtree))
end
function is_sub(vtree1::VTree, vtree2::VTree)::Bool
    return convert(Bool, SddLibrary.sdd_vtree_is_sub(vtree1.vtree, vtree2.vtree))
end
function lca(vtree1::VTree, vtree2::VTree)::VTree
    vtree =  SddLibrary.sdd_vtree_lca(vtree1.vtree, vtree2.vtree)
    return VTree(vtree)
end
function var_count(vtree::VTree)::SddLibrary.SddLiteral
    return SddLibrary.sdd_vtree_var_count(vtree.vtree)
end
function var(vtree::VTree)::SddLibrary.SddLiteral
    return SddLibrary.sdd_vtree_var(vtree.vtree)
end
function position(vtree::VTree)::SddLibrary.SddLiteral
    return SddLibrary.sdd_vtree_position(vtree.vtree)
end
# Vtree** sdd_vtree_location(Vtree* vtree, SddManager* manager);

# VTREE/SDD EDIT OPERATIONS
function rotate_left(vtree::VTree, manager::SddManager, limited::Union{Bool,Integer})::Bool
    return convert(Bool, SddLibrary.sdd_vtree_rotate_left(vtree.vtree, manager.manager, convert(Cint, limited)))
end
function rotate_right(vtree::VTree, manager::SddManager, limited::Union{Bool,Integer})::Bool
    return convert(Bool, SddLibrary.sdd_vtree_rotate_right(vtree.vtree, manager.manager, convert(Cint, limited)))
end
function swap(vtree::VTree, manager::SddManager, limited::Union{Bool,Integer})::Bool
    return convert(Bool, SddLibrary.sdd_vtree_swap(vtree.vtree, manager.manager, convert(Cint, limited)))
end

# LIMITS FOR VTREE/SDD EDIT OPERATIONS
function init_vtree_size_limit(vtree::VTree, manager::SddManager)
    SddLibrary.sdd_manager_init_vtree_size_limit(vtree.vtree, manager.manager)
end
function update_vtree_size_limit(manager::SddManager)
    SddLibrary.sdd_manager_update_vtree_size_limit(manager.manager)
end


# # VTREE STATE

# GARBAGE COLLECTION
function ref_count(node::SddNode)::SddLibrary.SddRefCount
    return SddLibrary.sdd_ref_count(node.node)
end
function ref(node::SddNode, manager::SddManager)::SddNode
    ref_node = SddLibrary.sdd_ref(node.node, manager.manager)
    return SddNode(ref_node, manager.manager)
end
function deref(node::SddNode, manager::SddManager)::SddNode
    ref_node = SddLibrary.sdd_deref(node.node, manager.manager)
    return SddNode(ref_node, manager.manager)
end
function garbage_collect(manager::SddManager)
    SddLibrary.sdd_manager_garbage_collect(manager.manager)
end
function garbage_collect(vtree::VTree, manager::SddManager)
    SddLibrary.sdd_manager_garbage_collect(vtree.vtree, manager.manager)
end
function garbage_collect_if(dead_node_threshold::Real, manager::SddManager)::Int32
    return SddLibrary.sdd_manager_garbage_collect_if(convert(Float32, dead_node_threshold), manager.manager)
end
function garbage_collect_if(dead_node_threshold::Real, vtree::VTree, manager::SddManager)::Int32
    return SddLibrary.sdd_manager_garbage_collect_if(convert(Float32, dead_node_threshold), vtree.vtree, manager.manager)
end

# MINIMIZATION
function  minimize(manager::SddManager; limited::Bool=false)
    if  !limited
        SddLibrary.sdd_manager_minimize(manager.manager)
    else
        SddLibrary.sdd_manager_minimize_limited(manager.manager)
    end
end
function minimize(vtree::VTree, manager::SddManager; limited::Bool=false)::VTree
    if !limited
        vtree = SddLibrary.sdd_vtree_minimize(vtree.vtree, manager.manager)
    else
        vtree = SddLibrary.sdd_vtree_minimize_limited(vtree.vtree, manager.manager)
    end
    return VTree(vtree)
end

function set_vtree_search_convergence_threshold(threshold::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_search_convergence_threshold(convert(Float32, threshold), manager.manager)
end

function set_vtree_search_time_limit(time_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_search_time_limit(convert(Float32, time_limit), manager.manager)
end
function set_vtree_fragment_time_limit(time_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_fragment_time_limit(convert(Float32, time_limit), manager.manager)
end
function set_vtree_operation_time_limit(time_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_operation_time_limit(convert(Float32, time_limit), manager.manager)
end
function set_vtree_apply_time_limit(time_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_apply_time_limit(convert(Float32, time_limit), manager.manager)
end
function set_vtree_operation_memory_limit(memory_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_operation_memory_limit(convert(Float32, memory_limit), manager.manager)
end
function set_vtree_operation_size_limit(size_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_operation_size_limit(convert(Float32, size_limit), manager.manager)
end
function set_vtree_cartesian_product_limit(size_limit::Real, manager::SddManager)
    SddLibrary.sdd_manager_set_vtree_cartesian_product_limit(convert(Float32, size_limit), manager.manager)
end

# WMC
function wmc_manager(node::SddNode, log_mode::Bool, manager::SddManager)::WmcManager
    wmc = SddLibrary.wmc_manager_new(node.node, convert(Cint, log_mode), manager.manager)
    return WmcManager(wmc)
end
function free(manager::WmcManager)
    SddLibrary.wmc_manager_free(manager.manager)
end
function set_literal_weight(node::SddNode, weight::Real, manager::WmcManager)
    literal = SddLibrary.sdd_node_literal(node.node)
    SddLibrary.wmc_set_literal_weight(literal, convert(SddLibrary.SddWmc, weight), manager.manager)
end
function propagate(manager::WmcManager)::SddLibrary.SddWmc
    return SddLibrary.wmc_propagate(manager.manager)
end
function zero(manager::WmcManager)::SddLibrary.SddWmc
    return SddLibrary.wmc_zero_weight(manager.manager)
end
function one(manager::WmcManager)::SddLibrary.SddWmc
    return SddLibrary.wmc_one_weight(manager.manager)
end
function weight(literal::Integer, manager::WmcManager)::SddLibrary.SddWmc
    return SddLibrary.wmc_literal_weight(convert(SddLibrary.SddLiteral, literal), manager.manager)
end
function derivative(literal::Integer, manager::WmcManager)::SddLibrary.SddWmc
    return SddLibrary.wmc_literal_derivative(convert(SddLibrary.SddLiteral, literal), manager.manager)
end
function probability(literal::Integer, manager::WmcManager)::SddLibrary.SddWmc
    return SddLibrary.wmc_literal_pr(convert(SddLibrary.SddLiteral, literal), manager.manager)
end




# CONVENIENCE METHODS
function conjoin(node1::SddNode, node2::SddNode)::SddNode
    node = SddLibrary.sdd_conjoin(node1.node, node2.node, node1.manager)
    return SddNode(node, node1.manager)
end
function disjoin(node1::SddNode, node2::SddNode)::SddNode
    node = SddLibrary.sdd_disjoin(node1.node, node2.node, node1.manager)
    return SddNode(node, node1.manager)
end
function negate(node::SddNode)::SddNode
    nodeptr = SddLibrary.sdd_negate(node.node, node.manager)
    return SddNode(nodeptr, node.manager)
end
function equiv(left::SddNode, right::SddNode)::SddNode
    return (!left | right) & (left | !right)
end
function model_count(node::SddNode; globally::Bool=false)::SddLibrary.SddModelCount
    if  !globally
        return SddLibrary.sdd_model_count(node.node, node.manager)
    else
        return SddLibrary.sdd_global_model_count(node.node, node.manager)
    end
end
function ref(node::SddNode)::SddNode
    ref_node = SddLibrary.sdd_ref(node.node, node.manager)
    return SddNode(ref_node, node.manager)
end
function deref(node::SddNode)::SddNode
    ref_node = SddLibrary.sdd_deref(node.node, node.manager)
    return SddNode(ref_node, node.manager)
end

function dot(filename::String, structure::Union{VTree,SddNode})
    save_as_dot(filename, structure)
end
function wmc_manager(node::SddNode; log_mode::Bool=true)::WmcManager
    wmc = SddLibrary.wmc_manager_new(node.node, convert(Cint, log_mode), node.manager)
    return WmcManager(wmc)
end

Base.:&(node1::SddNode, node2::SddNode) = conjoin(node1,node2)
Base.:|(node1::SddNode, node2::SddNode) = disjoin(node1,node2)
Base.:~(node::SddNode) = negate(node)
↔(left::SddNode, right::SddNode) = equiv(left,right)


# FNF methods
@with_kw struct CompilerOptions
    vtree_search_mode::Int32 = -1
    post_search::Bool = false
    verbose::Bool = false
end

function read_cnf(filename::String, manager::SddManager; compiler_options=CompilerOptions())::SddNode
    cnf = read_cnf(filename)
    sdd_node = fnf_to_sdd(cnf, manager.manager, compiler_options)
    return SddNode(sdd_node, manager.manager)
end
function read_dnf(filename::String, manager::SddManager; compiler_options=CompilerOptions())::SddNode
    dnf = read_dnf(filename)
    sdd_node = fnf_to_sdd(dnf, manager.manager, compiler_options)
    return SddNode(sdd_node, manager.manager)
end


export ↔
end
