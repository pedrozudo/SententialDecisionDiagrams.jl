using SDD

var_count = 4
var_order = [2,1,4,3]
vtree_type = "balanced"

vtree = SDD.vtree(var_count, var_order, vtree_type)
manager = SDD.manager(vtree)

println("constructing SDD ... ")
a, b, c, d = [SDD.literal(i,manager) for i in 1:4]
α = (a & b) | (b & c) | (c & d)
println("done")

println("saving sdd and vtree ... ")
SDD.dot("$(@__DIR__)/output/sdd.dot",α)
SDD.dot("$(@__DIR__)/output/vtree.dot",vtree)
println("done")
