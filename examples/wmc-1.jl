using SDD

# set up vtree and manager
vtree = SDD.read_vtree("$(@__DIR__)/input/simple.vtree")
sdd = SDD.sdd_manager(vtree)

println("Created an SDD with $(SDD.var_count(sdd)) variables")
root = SDD.read_cnf("$(@__DIR__)/input/simple.cnf", sdd, compiler_options=SDD.CompilerOptions(vtree_search_mode=-1))
# For DNF functions use `read_dnf_file`

# Model Counting
wmc = SDD.wmc_manager(root, log_mode=true)
w = SDD.propagate(wmc)
println("Model count: $(convert(Int32,exp(w)))")

# Weighted Model Counting
lits = [SDD.literal(i,sdd) for i in 1:SDD.var_count(sdd)]

# Positive literal weight
SDD.set_literal_weight(lits[1], log(0.5), wmc)
# Negative literal weight
SDD.set_literal_weight(~lits[1], log(0.5), wmc)

w = SDD.propagate(wmc)
println("Weighted model count: $(exp(w))")

# Visualize SDD and VTREE
println("saving sdd and vtree ... ")
SDD.dot("$(@__DIR__)/output/simple-vtree.dot", vtree)
SDD.dot("$(@__DIR__)/output/simple-sdd-cnf.dot", root)
