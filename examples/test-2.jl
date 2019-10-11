using SDD

# set up vtree and manager
var_count = 4
vtree_type = "right"
v = vtree(var_count, vtree_type)
m = manager(v)

x = [literal(i,m) for i in 1:5]

# construct the term X_1 ^ X_2 ^ X_3 ^ X_4
α =  x[1] &  x[2] & x[3] & x[4]

# construct the term ~X_1 ^ X_2 ^ X_3 ^ X_4
β  = ~x[1] &  x[2] & x[3] & x[4]

# construct the term ~X_1 ^ ~X_2 ^ X_3 ^ X_4
γ = ~x[1] & ~x[2] & x[3] & x[4]

println("== before referencing:")
println("  live sdd size = $(Sdd.live_size(m))")
println("  dead sdd size = $(Sdd.dead_size(m))")

# ref SDDs so that they are not garbage collected
Sdd.ref(α)
Sdd.ref(β)
Sdd.ref(γ)
println("== after referencing:")
println("  live sdd size = $(Sdd.live_size(m))")
println("  dead sdd size = $(Sdd.dead_size(m))")

# garbage collect
Sdd.garbage_collect(m)
println("== after garbage collection:");
println("  live sdd size = $(Sdd.live_size(m))")
println("  dead sdd size = $(Sdd.dead_size(m))")

Sdd.deref(α)
Sdd.deref(β)
Sdd.deref(γ)

println("saving vtree & shared sdd ...")

Sdd.dot("output/shared-vtree.dot", v)
Sdd.shared_save_as_dot("output/shared.dot", m)
