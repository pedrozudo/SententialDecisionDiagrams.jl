module SddLibrary


# @static if Sys.isunix()
#     @static if Sys.islinux()
#         const LIBSDD = "../deps/sdd-2.0/Linux/libsdd"
#     elseif Sys.isdarwin
#         const LIBSDD = "../deps/sdd-2.0/Darwin/libsdd"
#     else
#         LoadError("sddapi.jl", 0, "Sdd library only available on Linux and Darwin")
#     end
# else
#     LoadError("sddapi.jl", 0, "Sdd library only available on Linux and Darwin")
# end


try
  @compat Libdl.dlopen(joinpath("libsdd.so"), Libdl.RTLD_LAZY|Libdl.RTLD_DEEPBIND|Libdl.RTLD_GLOBAL)
catch e
  error("Could not load z3 shared libraries")
  rethrow(e)
end

const SddSize = Csize_t
const SddNodeSize = Cuint
const SddRefCount = Cuint
const SddModelCount = Culonglong
const SddWMC = Cdouble
const SddLiteral = UInt64

const SddID = SddSize

const SddBoolOp = Cushort

struct VTree_c end
struct SddNode_c end
struct SddManager_c end
struct SddWmcManager_c end


# SDD MANAGER FUNCTIONS
function sdd_manager_new(vtree::Ptr{VTree_c})::Ptr{SddManager_c}
    return ccall((:sdd_manager_new, LIBSDD), Ptr{SddManager_c}, (Ptr{VTree_c},), vtree)
end
function sdd_manager_print(manager::Ptr{SddManager_c})
    return ccall((:sdd_manager_print, LIBSDD), Cvoid, (Ptr{SddManager_c},), manager)
end


function sdd_manager_free(manager::Ptr{SddManager_c})
    ccall((:sdd_manager_free, LIBSDD), Cvoid, (Ptr{SddManager_c},), manager)
end


# TERMINAL SDDS
function sdd_manager_true(manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_manager_true, LIBSDD), Ptr{SddNode_c}, (Ptr{SddManager_c},), manager)
end
function sdd_manager_false(manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_manager_false, LIBSDD), Ptr{SddNode_c}, (Ptr{SddManager_c},), manager)
end
function sdd_manager_literal(literal::UInt64, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_manager_literal, LIBSDD), Ptr{SddNode_c}, (UInt64, Ptr{SddManager_c}), literal, manager)
end

# SDD QUERIES AND TRANSFORMATIONS
function sdd_apply(node1::Ptr{SddNode_c}, node2::Ptr{SddNode_c}, op::SddBoolOp ,manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_apply, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c}, Ptr{SddNode_c}, SddBoolOp, Ptr{SddManager_c}), node1, node2, op, manager)
end
function sdd_conjoin(node1::Ptr{SddNode_c}, node2::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_conjoin, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c}, Ptr{SddNode_c}, Ptr{SddManager_c}), node1, node2, manager)
end
function sdd_disjoin(node1::Ptr{SddNode_c}, node2::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_disjoin, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c}, Ptr{SddNode_c}, Ptr{SddManager_c}), node1, node2, manager)
end
function sdd_negate(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_negate, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c}, Ptr{SddManager_c}), node, manager)
end
function sdd_condition(lit::SddLiteral, node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_condition, LIBSDD), Ptr{SddNode_c}, (SddLiteral, Ptr{SddNode_c}, Ptr{SddManager_c}), lit, node, manager)
end
function sdd_exists(lit::SddLiteral, node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_exists, LIBSDD), Ptr{SddNode_c}, (SddLiteral, Ptr{SddNode_c}, Ptr{SddManager_c}), lit, node, manager)
end
function sdd_exists_multiple(exists_map::Array{Cint,1}, node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_exists_multiple, LIBSDD), Ptr{SddNode_c}, (Array{Cint,1}, Ptr{SddNode_c}, Ptr{SddManager_c}), exists_map, node, manager)
end
function sdd_exists_multiple_static(exists_map::Array{Cint,1}, node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_exists_multiple_static, LIBSDD), Ptr{SddNode_c}, (Array{Cint,1}, Ptr{SddNode_c}, Ptr{SddManager_c}), exists_map, node, manager)
end
function sdd_forall(lit::SddLiteral, node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_forall, LIBSDD), Ptr{SddNode_c}, (SddLiteral, Ptr{SddNode_c}, Ptr{SddManager_c}), lit, node, manager)
end
function sdd_minimize_cardinality(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_minimize_cardinality, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c}, Ptr{SddManager_c}), node, manager)
end
function sdd_global_minimize_cardinality(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_global_minimize_cardinality, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c}, Ptr{SddManager_c}), node, manager)
end
function sdd_minimum_cardinality(node::Ptr{SddNode_c})::SddLiteral
    return ccall((:sdd_minimum_cardinality, LIBSDD), SddLiteral, (Ptr{SddNode_c}, ), node)
end
function sdd_model_count(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::SddModelCount
    return ccall((:sdd_model_count, LIBSDD), SddModelCount, (Ptr{SddNode_c}, Ptr{SddManager_c}), node, manager)
end
function sdd_global_model_count(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::SddModelCount
    return ccall((:sdd_global_model_count, LIBSDD), SddModelCount, (Ptr{SddNode_c}, Ptr{SddManager_c}), node, manager)
end


# // SDD NAVIGATION
function sdd_node_is_true(node::Ptr{SddNode_c})::Int32
    return ccall((:sdd_node_is_true, LIBSDD), Cint, (Ptr{SddNode_c}, ), node)
end
function sdd_node_is_false(node::Ptr{SddNode_c})::Int32
    return ccall((:sdd_node_is_false, LIBSDD), Cint, (Ptr{SddNode_c}, ), node)
end
function sdd_node_is_literal(node::Ptr{SddNode_c})::Int32
    return ccall((:sdd_node_is_literal, LIBSDD), Cint, (Ptr{SddNode_c}, ), node)
end
function sdd_node_is_decision(node::Ptr{SddNode_c})::Int32
    return ccall((:sdd_node_is_decision, LIBSDD), Cint, (Ptr{SddNode_c}, ), node)
end
function sdd_node_size(node::Ptr{SddNode_c})::SddNodeSize
    return ccall((:sdd_node_size, LIBSDD), SddNodeSize, (Ptr{SddNode_c}, ), node)
end
function sdd_node_literal(node::Ptr{SddNode_c})::SddLiteral
    return ccall((:sdd_node_literal, LIBSDD), SddLiteral, (Ptr{SddNode_c}, ), node)
end
function sdd_node_elements(node::Ptr{SddNode_c})::Ptr{Ptr{SddNode_c}}
    return ccall((:sdd_node_elements, LIBSDD), Ptr{Ptr{SddNode_c}}, (Ptr{SddNode_c}, ), node)
end
function sdd_node_set_bit(bit::Int32, node::Ptr{SddNode_c})
    ccall((:sdd_node_set_bit, LIBSDD), Cvoid, (Cint, Ptr{SddNode_c}), bit, node)
end
function sdd_node_bit(node::Ptr{SddNode_c})::Int32
    return ccall((:sdd_node_bit, LIBSDD), Int32, (Ptr{SddNode_c}, ), node)
end

# # SDD FUNCTIONS
#
# SDD FILE I/O
function sdd_read(filename::Ptr{UInt8}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_read, LIBSDD), Ptr{SddNode_c}, (Ptr{UInt8}, Ptr{SddManager_c}), filename, manager)
end
function sdd_save(filename::Ptr{UInt8}, node::Ptr{SddNode_c})
    ccall((:sdd_save, LIBSDD), Cvoid, (Ptr{UInt8}, Ptr{SddNode_c}), filename, node)
end
function sdd_save_as_dot(filename::Ptr{UInt8}, node::Ptr{SddNode_c})
    ccall((:sdd_save_as_dot, LIBSDD), Cvoid, (Ptr{UInt8}, Ptr{SddNode_c}), filename, node)
end
function sdd_shared_save_as_dot(filename::Ptr{UInt8}, manager::Ptr{SddManager_c})
    ccall((:sdd_shared_save_as_dot, LIBSDD), Cvoid, (Ptr{UInt8}, Ptr{SddManager_c}), filename, manager)
end

# // SDD SIZE AND NODE COUNT
# //SDD
function sdd_count(node::Ptr{SddNode_c})::SddSize
    return ccall((:sdd_count, LIBSDD), SddSize, (Ptr{SddNode_c},), node)
end
function sdd_size(node::Ptr{SddNode_c})::SddSize
    return ccall((:sdd_size, LIBSDD), SddSize, (Ptr{SddNode_c},), node)
end
# TODO SddSize sdd_shared_size(SddNode** nodes, SddSize count);
# //SDD OF MANAGER
manager_size_fnames_c = [
    "sdd_manager_size", "sdd_manager_live_size", "sdd_manager_dead_size",
    "sdd_manager_count", "sdd_manager_live_count", "sdd_manager_dead_count"
]
for fnc in manager_size_fnames_c
    @eval begin
        function $(Symbol(fnc))(manager::Ptr{SddManager_c})::SddSize
            return ccall(($(:($(fnc))), LIBSDD), SddSize, (Ptr{SddManager_c},), manager)
        end
    end
end

# SDD SIZE OF VTREE
vtree_size_fnames_c = [
    "sdd_vtree_size", "sdd_vtree_live_size", "sdd_vtree_dead_size",
    "sdd_vtree_size_at", "sdd_vtree_live_size_at", "sdd_vtree_dead_size_at",
    "sdd_vtree_size_above", "sdd_vtree_live_size_above", "sdd_vtree_dead_size_above",
    "sdd_vtree_count", "sdd_vtree_live_count", "sdd_vtree_dead_count",
    "sdd_vtree_count_at", "sdd_vtree_live_count_at", "sdd_vtree_dead_count_at",
    "sdd_vtree_count_above", "sdd_vtree_live_count_above", "sdd_vtree_dead_count_above"
]
for fnc in vtree_size_fnames_c
    @eval begin
        function $(Symbol(fnc))(vtree::Ptr{VTree_c})::SddSize
            return ccall(($(:($(fnc))), LIBSDD), SddSize, (Ptr{VTree_c},), vtree)
        end
    end
end


# CREATING VTREES
function sdd_vtree_new(var_count::SddLiteral, vtree_type::Ptr{UInt8})::Ptr{VTree_c}
    return ccall((:sdd_vtree_new, LIBSDD), Ptr{VTree_c}, (SddLiteral, Ptr{UInt8}), var_count, vtree_type)
end
function sdd_vtree_new_with_var_order(var_count::SddLiteral, var_order::Array{SddLiteral,1}, vtree_type::Ptr{UInt8})::Ptr{VTree_c}
    return ccall((:sdd_vtree_new_with_var_order, LIBSDD), Ptr{VTree_c}, (SddLiteral, Ptr{SddLiteral}, Ptr{UInt8}), var_count, var_order, vtree_type)
end
function sdd_vtree_new_X_constrained(var_count::SddLiteral, is_X_var::Array{SddLiteral,1}, vtree_type::Ptr{UInt8})::Ptr{VTree_c}
    return ccall((:sdd_vtree_new_X_constrained, LIBSDD), Ptr{VTree_c}, (SddLiteral, Ptr{SddLiteral}, Ptr{UInt8}), var_count, is_X_var, vtree_type)
end
function sdd_vtree_free(vtree::Ptr{VTree_c})
    ccall((:sdd_vtree_free, LIBSDD), Cvoid, (Ptr{VTree_c},), vtree)
end


# VTREE FILE I/O
function sdd_vtree_read(filename::Ptr{UInt8})::Ptr{VTree_c}
    return ccall((:sdd_vtree_read, LIBSDD), Ptr{VTree_c}, (Ptr{UInt8},), filename)
end
function sdd_vtree_save(filename::Ptr{UInt8}, vtree::Ptr{VTree_c})
    ccall((:sdd_vtree_save, LIBSDD), Cvoid, (Ptr{UInt8}, Ptr{VTree_c}), filename, vtree)
end
function sdd_vtree_save_as_dot(filename::Ptr{UInt8}, vtree::Ptr{VTree_c})
    ccall((:sdd_vtree_save_as_dot, LIBSDD), Cvoid, (Ptr{UInt8}, Ptr{VTree_c}), filename, vtree)
end


# # SDD MANAGER VTREE
#
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
function sdd_ref_count(node::Ptr{SddNode_c})::SddRefCount
    return ccall((:sdd_ref_count, LIBSDD), SddRefCount, (Ptr{SddNode_c},), node)
end
function sdd_ref(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_ref, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c},Ptr{SddManager_c}), node, manager)
end
function sdd_deref(node::Ptr{SddNode_c}, manager::Ptr{SddManager_c})::Ptr{SddNode_c}
    return ccall((:sdd_deref, LIBSDD), Ptr{SddNode_c}, (Ptr{SddNode_c},Ptr{SddManager_c}), node, manager)
end
function sdd_manager_garbage_collect(manager::Ptr{SddManager_c})
    ccall((:sdd_manager_garbage_collect, LIBSDD), Cvoid, (Ptr{SddManager_c},), manager)
end
function sdd_vtree_garbage_collect(vtree::Ptr{VTree_c}, manager::Ptr{SddManager_c})
    ccall((:sdd_vtree_garbage_collect, LIBSDD), Cvoid, (Ptr{VTree_c}, Ptr{SddManager_c}), vtree, manager)
end
function sdd_manager_garbage_collect_if(dead_node_threshold::Float32, manager::Ptr{SddManager_c})::Int32
    return ccall((:sdd_manager_garbage_collect_if, LIBSDD), Int32, (Float32, Ptr{SddManager_c}), dead_node_threshold, manager)
end
function sdd_vtree_garbage_collect_if(dead_node_threshold::Float32, vtree::Ptr{VTree_c}, manager::Ptr{SddManager_c})::Int32
    return ccall((:sdd_manager_garbage_collect_if, LIBSDD), Int32, (Float32, Ptr{VTree_c}, Ptr{SddManager_c}), dead_node_threshold, vtree, manager)
end

# MINIMIZATION
function sdd_manager_minimize(manager::Ptr{SddManager_c})
    ccall((:sdd_manager_minimize, LIBSDD), Cvoid, (Ptr{SddManager_c},), manager)
end
function sdd_vtree_minimize(vtree::Ptr{VTree_c}, manager::Ptr{SddManager_c})::Ptr{VTree_c}
    return ccall((:sdd_manager_minimize, LIBSDD), Ptr{VTree_c}, (Ptr{VTree_c}, Ptr{SddManager_c}), vtree, manager)
end
function sdd_manager_minimize_limited(manager::Ptr{SddManager_c})
    ccall((:sdd_manager_minimize_limited, LIBSDD), Cvoid, (Ptr{SddManager_c},), manager)
end
function sdd_vtree_minimize_limited(vtree::Ptr{VTree_c}, manager::Ptr{SddManager_c})::Ptr{VTree_c}
    return ccall((:sdd_vtree_minimize_limited, LIBSDD), Ptr{VTree_c}, (Ptr{VTree_c}, Ptr{SddManager_c}), vtree, manager)
end

function sdd_manager_set_vtree_search_convergence_threshold(threshold::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_search_convergence_threshold, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), threshold, manager)
end

function sdd_manager_set_vtree_search_time_limit(time_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_search_time_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), time_limit, manager)
end
function sdd_manager_set_vtree_fragment_time_limit(time_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_fragment_time_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), time_limit, manager)
end
function sdd_manager_set_vtree_operation_time_limit(time_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_operation_time_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), time_limit, manager)
end
function sdd_manager_set_vtree_apply_time_limit(time_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_apply_time_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), time_limit, manager)
end
function sdd_manager_set_vtree_operation_memory_limit(memory_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_operation_memory_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), memory_limit, manager)
end
function sdd_manager_set_vtree_operation_size_limit(size_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_operation_size_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), size_limit, manager)
end
function sdd_manager_set_vtree_cartesian_product_limit(size_limit::Float32, manager::Ptr{SddManager_c})
    ccall((:sdd_manager_set_vtree_cartesian_product_limit, LIBSDD), Cvoid, (Float32, Ptr{SddManager_c}), size_limit, manager)
end



# # WMC
#





end









# TO BE WRAPPED

# // SDD MANAGER FUNCTIONS
# SddManager* sdd_manager_create(SddLiteral var_count, int auto_gc_and_minimize);
# SddManager* sdd_manager_copy(SddSize size, SddNode** nodes, SddManager* from_manager);
# void sdd_manager_auto_gc_and_minimize_on(SddManager* manager);
# void sdd_manager_auto_gc_and_minimize_off(SddManager* manager);
# int sdd_manager_is_auto_gc_and_minimize_on(SddManager* manager);
# void sdd_manager_set_minimize_function(SddVtreeSearchFunc func, SddManager* manager);
# void sdd_manager_unset_minimize_function(SddManager* manager);
# void* sdd_manager_options(SddManager* manager);
# void sdd_manager_set_options(void* options, SddManager* manager);
# int sdd_manager_is_var_used(SddLiteral var, SddManager* manager);
# Vtree* sdd_manager_vtree_of_var(const SddLiteral var, const SddManager* manager);
# Vtree* sdd_manager_lca_of_literals(int count, SddLiteral* literals, SddManager* manager);
# SddLiteral sdd_manager_var_count(SddManager* manager);
# void sdd_manager_var_order(SddLiteral* var_order, SddManager *manager);
# void sdd_manager_add_var_before_first(SddManager* manager);
# void sdd_manager_add_var_after_last(SddManager* manager);
# void sdd_manager_add_var_before(SddLiteral target_var, SddManager* manager);
# void sdd_manager_add_var_after(SddLiteral target_var, SddManager* manager);
#
# // SDD FUNCTIONS
# SddSize sdd_id(SddNode* node);
# int sdd_garbage_collected(SddNode* node, SddSize id);
# Vtree* sdd_vtree_of(SddNode* node);
# SddNode* sdd_copy(SddNode* node, SddManager* dest_manager);
# SddNode* sdd_rename_variables(SddNode* node, SddLiteral* variable_map, SddManager* manager);
# int* sdd_variables(SddNode* node, SddManager* manager);
#
# // SDD MANAGER VTREE
# Vtree* sdd_manager_vtree(const SddManager* manager);
# Vtree* sdd_manager_vtree_copy(const SddManager* manager);
#
# // VTREE NAVIGATION
# Vtree* sdd_vtree_left(const Vtree* vtree);
# Vtree* sdd_vtree_right(const Vtree* vtree);
# Vtree* sdd_vtree_parent(const Vtree* vtree);
#
# // VTREE FUNCTIONS
# int sdd_vtree_is_leaf(const Vtree* vtree);
# int sdd_vtree_is_sub(const Vtree* vtree1, const Vtree* vtree2);
# Vtree* sdd_vtree_lca(Vtree* vtree1, Vtree* vtree2, Vtree* root);
# SddLiteral sdd_vtree_var_count(const Vtree* vtree);
# SddLiteral sdd_vtree_var(const Vtree* vtree);
# SddLiteral sdd_vtree_position(const Vtree* vtree);
# Vtree** sdd_vtree_location(Vtree* vtree, SddManager* manager);
#
# // VTREE/SDD EDIT OPERATIONS
# int sdd_vtree_rotate_left(Vtree* vtree, SddManager* manager, int limited);
# int sdd_vtree_rotate_right(Vtree* vtree, SddManager* manager, int limited);
# int sdd_vtree_swap(Vtree* vtree, SddManager* manager, int limited);
#
# // LIMITS FOR VTREE/SDD EDIT OPERATIONS
# void sdd_manager_init_vtree_size_limit(Vtree* vtree, SddManager* manager);
# void sdd_manager_update_vtree_size_limit(SddManager* manager);
#
# // VTREE STATE
# int sdd_vtree_bit(const Vtree* vtree);
# void sdd_vtree_set_bit(int bit, Vtree* vtree);
# void* sdd_vtree_data(Vtree* vtree);
# void sdd_vtree_set_data(void* data, Vtree* vtree);
# void* sdd_vtree_search_state(const Vtree* vtree);
# void sdd_vtree_set_search_state(void* search_state, Vtree* vtree);
#
# // WMC
# WmcManager* wmc_manager_new(SddNode* node, int log_mode, SddManager* manager);
# void wmc_manager_free(WmcManager* wmc_manager);
# void wmc_set_literal_weight(const SddLiteral literal, const SddWmc weight, WmcManager* wmc_manager);
# SddWmc wmc_propagate(WmcManager* wmc_manager);
# SddWmc wmc_zero_weight(WmcManager* wmc_manager);
# SddWmc wmc_one_weight(WmcManager* wmc_manager);
# SddWmc wmc_literal_weight(const SddLiteral literal, const WmcManager* wmc_manager);
# SddWmc wmc_literal_derivative(const SddLiteral literal, const WmcManager* wmc_manager);
# SddWmc wmc_literal_pr(const SddLiteral literal, const WmcManager* wmc_manager);
#
