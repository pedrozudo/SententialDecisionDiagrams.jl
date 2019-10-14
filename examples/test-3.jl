using SDD

# set up vtree and manager
v = SDD.read_vtree("$(@__DIR__)/input/opt-swap.vtree")
m = manager(v)

println("reading sdd from file ...")
α = SDD.read_sdd("$(@__DIR__)/input/opt-swap.sdd", m)
println("sdd size = $(SDD.size(α))")

# ref, perform the minimization, and then de-ref
SDD.ref(α)
println("minimizing sdd size ... ")
SDD.minimize(m)  # see also SDD.minimize(m,limited=true)
println("done!")
println("sdd size = $(SDD.size(α))")
SDD.deref(α)

# augment the SDD
println("augmenting sdd ...")
β = α & (literal(4,m) | literal(5,m))
println("sdd size = $(SDD.size(β))")

# ref, perform the minimization again on new SDD, and then de-ref
SDD.ref(β)
println("minimizing sdd ... ")
SDD.minimize(m)
println("done!")
println("sdd size = $(SDD.size(β))")
SDD.deref(β)
