using SDD

var_count = 4
var_order = [2,1,4,3]
vtree_type = "balanced"

v = vtree(var_count, var_order, vtree_type)
m = manager(v)

println("constructing SDD ... ")
a, b, c, d = [literal(i,m) for i in 1:4]
α = (a & b) | (b & c) | (c & d)
println("done")

println("saving sdd and vtree ... ")
SDD.dot("output/sdd.dot",α)
SDD.dot("output/vtree.dot",v)
println("done")
