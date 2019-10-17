include("../src/SDD.jl")
using .SDD

# set up vtree and manager
vtree = SDD.read_vtree("$(@__DIR__)/input/simple.vtree")
manager = SDD.manager(vtree)

println("Created an SDD with $(SDD.var_count(manager)) variables")
root = SDD.read_cnf("$(@__DIR__)/input/simple.cnf", manager, compiler_options=SDD.CompilerOptions(vtree_search_mode=1))
println(root)
#     # For DNF functions use `read_dnf_file`
#     # If the vtree is not given, you can also use 'from_cnf_file`
#
#     # Model Counting
#     wmc = root.wmc(log_mode=True)
#     w = wmc.propagate()
#     print(f"Model count: {int(math.exp(w))}")
#
#     # Weighted Model Counting
#     lits = [None] + [sdd.literal(i) for i in range(1, sdd.var_count() + 1)]
#     # Positive literal weight
#     wmc.set_literal_weight(lits[1], math.log(0.5))
#     # Negative literal weight
#     wmc.set_literal_weight(-lits[1], math.log(0.5))
#     w = wmc.propagate()
#     print(f"Weighted model count: {math.exp(w)}")
#
#     # Visualize SDD and VTREE
#     print("saving sdd and vtree ... ", end="")
#     with open(here / "output" / "sdd.dot", "w") as out:
#         print(sdd.dot(), file=out)
#     with open(here / "output" / "vtree.dot", "w") as out:
#         print(vtree.dot(), file=out)
#     print("done")
#
#
# if __name__ == "__main__":
#     main()
