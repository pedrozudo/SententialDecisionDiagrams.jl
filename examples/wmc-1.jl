include("../src/SDD.jl")
using .SDD

# set up vtree and manager
vtree = SDD.read_vtree("$(@__DIR__)/input/simple.vtree")
sdd = SDD.sdd_manager(vtree)

println("Created an SDD with $(SDD.var_count(sdd)) variables")
root = SDD.read_cnf("$(@__DIR__)/input/simple.cnf", sdd, compiler_options=SDD.CompilerOptions(vtree_search_mode=-1))
# For DNF functions use `read_dnf_file`

# Model Counting
wmc = SDD.wmc_manager(root, log_mode=true)
println(wmc)
println(SDD.one(wmc))
println(SDD.zero(wmc))
w = SDD.propagate(wmc)
# println(wmc)
#     print(f"Model count: {int(math.exp(w))}")
#
# Weighted Model Counting
# lits = [SDD.literal(i,sdd) for i in 1:SDD.var_count(sdd)]
# println(lits)
# Positive literal weight
# SDD.set_literal_weight(lits[1], log(0.5), wmc)
#     # Negative literal weight
#     wmc.set_literal_weight(-lits[1], math.log(0.5))
#     w = wmc.propagate()
#     print(f"Weighted model count: {math.exp(w)}")
#
#     # Visualize SDD and VTREE
#     print("saving sdd and vtree ... ", end="")
#     with open(here / "output" / "sdd.dot", "w") as out:
#         print(sdd.dot(), file=out)
# with open(here / "output" / "vtree.dot", "w") as out:
#         print(vtree.dot(), file=out)
# println("done")
