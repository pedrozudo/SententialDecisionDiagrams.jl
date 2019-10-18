using SDD

# set up vtree and manager
vtree = SDD.read_vtree("$(@__DIR__)/input/rotate-left.vtree")
manager = SDD.sdd_manager(vtree)

# construct the term X_1 ^ X_2 ^ X_3 ^ X_4
x = [SDD.literal(i,manager) for i in 1:5]
α = x[1] & x[2] & x[3] & x[4]

# to perform a rotate, we need the manager's vtree
manager_vtree = SDD.vtree(manager)
manager_vtree_right = SDD.right(manager_vtree)

println("saving vtree & sdd ...")
SDD.dot("$(@__DIR__)/output/before-rotate-vtree.dot", α)

# ref alpha (so it is not gc'd)
SDD.ref(α)

# garbage collect (no dead nodes when performing vtree operations)
println("dead sdd nodes = $(SDD.dead_count(manager))")
println("garbage collection ...")
SDD.garbage_collect(manager)
println("dead sdd nodes = $(SDD.dead_count(manager))")

println("left rotating ... ")
succeeded = SDD.rotate_left(manager_vtree_right,manager,0)
if succeeded == 1; println("succeeded!") else println("did not succeed!") end

# deref alpha, since ref's are no longer needed
SDD.deref(α)

# the root changed after rotation, so get the manager's vtree again
# this time using root_location
manager_vtree = SDD.vtree(manager)

println("saving vtree & sdd ...")
SDD.dot("$(@__DIR__)/output/after-rotate-vtree.dot", manager_vtree)
SDD.dot("$(@__DIR__)/output/after-rotate-sdd.dot", α)
