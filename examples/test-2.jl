using SententialDecisionDiagrams
const SDD = SententialDecisionDiagrams

# set up vtree and manager
var_count = 4
vtree_type = "right"
vtree = SDD.vtree(var_count, vtree_type)
manager = SDD.sdd_manager(vtree)

x = [SDD.literal(i,manager) for i in 1:5]

# construct the term X_1 ^ X_2 ^ X_3 ^ X_4
α =  x[1] &  x[2] & x[3] & x[4]

# construct the term ~X_1 ^ X_2 ^ X_3 ^ X_4
β  = ~x[1] &  x[2] & x[3] & x[4]

# construct the term ~X_1 ^ ~X_2 ^ X_3 ^ X_4
γ = ~x[1] & ~x[2] & x[3] & x[4]

println("before referencing:")
println("live sdd size = $(SDD.live_size(manager))")
println("dead sdd size = $(SDD.dead_size(manager))")

# ref SDDs so that they are not garbage collected
SDD.ref(α)
SDD.ref(β)
SDD.ref(γ)
println("after referencing:")
println("live sdd size = $(SDD.live_size(manager))")
println("dead sdd size = $(SDD.dead_size(manager))")

# garbage collect
SDD.garbage_collect(manager)
println("after garbage collection:");
println("live sdd size = $(SDD.live_size(manager))")
println("dead sdd size = $(SDD.dead_size(manager))")

SDD.deref(α)
SDD.deref(β)
SDD.deref(γ)

println("saving vtree & shared sdd ...")

SDD.dot("$(@__DIR__)/output/shared-vtree.dot", vtree)
SDD.shared_save_as_dot("$(@__DIR__)/output/shared.dot", manager)
