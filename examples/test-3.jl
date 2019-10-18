using SDD

# set up vtree and manager
vtree = SDD.read_vtree("$(@__DIR__)/input/opt-swap.vtree")
manager = SDD.sdd_manager(vtree)

println("reading sdd from file ...")
α = SDD.read_sdd("$(@__DIR__)/input/opt-swap.sdd", manager)
println("sdd size = $(SDD.size(α))")

# ref, perform the minimization, and then de-ref
SDD.ref(α)
println("minimizing sdd size ... ")
SDD.minimize(manager)  # see also SDD.minimize(m,limited=true)
println("done!")
println("sdd size = $(SDD.size(α))")
SDD.deref(α)

# augment the SDD
println("augmenting sdd ...")
β = α & (SDD.literal(4,manager) | SDD.literal(5,manager))
println("sdd size = $(SDD.size(β))")

# ref, perform the minimization again on new SDD, and then de-ref
SDD.ref(β)
println("minimizing sdd ... ")
SDD.minimize(manager)
println("done!")
println("sdd size = $(SDD.size(β))")
SDD.deref(β)
