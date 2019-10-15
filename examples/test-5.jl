using SDD

# set up vtree and manager
vtree = SDD.read_vtree("$(@__DIR__)/input/big-swap.vtree")
manager = SDD.manager(vtree)

println("reading sdd from file ...")
α = SDD.read_sdd("$(@__DIR__)/input/big-swap.sdd", manager)
println("sdd size = $(SDD.size(α))")

# to perform a swap, we need the manager's vtree
manager_vtree = SDD.vtree(manager)

# ref alpha (no dead nodes when swapping)
SDD.ref(α)
#
# # using size of sdd normalized for manager_vtree as baseline for limit
SDD.init_vtree_size_limit(manager_vtree, manager)
#
limit = 2.0
SDD.set_vtree_operation_size_limit(limit, manager)

println("modifying vtree (swap node 7) (limit growth by $(limit)x) ... ")
succeeded = SDD.swap(manager_vtree, manager, 1)
if succeeded == 1; println("succeeded!") else println("did not succeed!") end
println("sdd size = $(SDD.size(α))")

println("modifying vtree (swap node 7) (no limit) ... ")
succeeded = SDD.swap(manager_vtree, manager, 0)
if succeeded == 1; println("succeeded!") else println("did not succeed!") end
println("sdd size = $(SDD.size(α))")

println("updating baseline of size limit ...")
SDD.update_vtree_size_limit(manager)

left_vtree = SDD.left(manager_vtree)
limit = 1.2
SDD.set_vtree_operation_size_limit(limit, manager)
println("modifying vtree (swap node 5) (limit growth by $(limit)x) ... ")
succeeded = SDD.swap(left_vtree, manager, 1)
if succeeded == 1; println("succeeded!") else println("did not succeed!") end
println("sdd size = $(SDD.size(α))")

limit = 1.3
SDD.set_vtree_operation_size_limit(limit, manager)
println("modifying vtree (swap node 5) (limit growth by $(limit)x) ... ")
succeeded = SDD.swap(left_vtree, manager, 1)
if succeeded == 1; println("succeeded!") else println("did not succeed!") end
println("sdd size = $(SDD.size(α))")

# deref alpha, since ref's are no longer needed
SDD.deref(α)
