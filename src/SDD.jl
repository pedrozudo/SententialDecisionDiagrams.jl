module SDD

include("sddapi.jl")
include("compiler.jl")

using .SddLibrary
using .SddCompiler

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
    prime::SddLibrary.SddNode_c
    sub::SddLibrary.SddNode_c
end

function str_to_char(vtree_type::String)::Ptr{UInt8}
    return pointer(vtree_type)
end

# SDD MANAGER FUNCTIONS
function manager(vtree::VTree)::SddManager
    manager = SddLibrary.sdd_manager_new(vtree.vtree)
    return SddManager(manager)
end
function Base.print(manager::SddManager)
    SddLibrary.sdd_manager_print(manager.manager)
end

function free(manager::SddManager)
    SddLibrary.sdd_manager_free(manager.manager)
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
    node = SddLibrary.sdd_manager_literal(convert(UInt64, literal), manager.manager)
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
    node = SddLibrary.sdd_condition(convert(SddLiteral,lit), node.node, manager.manager)
    return SddNode(node, manager.manager)
end
function exists(lit::Integer, node::SddNode, manager::SddManager)::SddNode
    node = SddLibrary.sdd_exists(convert(SddLiteral,lit), node.node, manager.manager)
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
    node = SddLibrary.sdd_forall(convert(SddLiteral,lit), node.node, manager.manager)
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
        p = unsafe_load(e)
        s =unsafe_load(e+1)
        push!(primesubs, PrimeSub(p,s))
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
# //SDD OF MANAGER
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

# # VTREE NAVIGATION
#
# # VTREE FUNCTIONS
#
# # VTREE/SDD EDIT OPERATIONS
#
# # LIMITS FOR VTREE/SDD EDIT OPERATIONS
#
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

# # WMC
#

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



Base.:&(node1::SddNode, node2::SddNode) = conjoin(node1,node2)
Base.:|(node1::SddNode, node2::SddNode) = disjoin(node1,node2)
Base.:~(node::SddNode) = negate(node)
↔(left::SddNode, right::SddNode) = equiv(left,right)

export vtree, manager, literal, free, ↔

end
