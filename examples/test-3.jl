include("../src/Sdd.jl")
using .Sdd

# set up vtree and manager
v = Sdd.read_vtree("input/opt-swap.vtree")
m = manager(v)

println("reading sdd from file ...")
α = Sdd.read_sdd("input/opt-swap.sdd", m)
println("sdd size = $(Sdd.size(α))")

# ref, perform the minimization, and then de-ref
Sdd.ref(α)
println("minimizing sdd size ... ")
Sdd.minimize(m)  # see also Sdd.minimize(m,limited=true)
println("done!")
println("sdd size = $(Sdd.size(α))")
Sdd.deref(α)

# augment the SDD
println("augmenting sdd ...")
β = α & (literal(4,m) | literal(5,m))
println("sdd size = $(Sdd.size(β))")

# ref, perform the minimization again on new SDD, and then de-ref
Sdd.ref(β)
println("minimizing sdd ... ")
Sdd.minimize(m)
println("done!")
println("sdd size = $(Sdd.size(β))")
Sdd.deref(β)
