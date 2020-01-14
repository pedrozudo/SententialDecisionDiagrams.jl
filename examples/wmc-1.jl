using SententialDecisionDiagrams

# set up vtree and manager
vtree = SententialDecisionDiagrams.read_vtree("$(@__DIR__)/input/simple.vtree")
sdd = SententialDecisionDiagrams.sdd_manager(vtree)

println("Created an SententialDecisionDiagrams with $(SententialDecisionDiagrams.var_count(sdd)) variables")
root = SententialDecisionDiagrams.read_cnf("$(@__DIR__)/input/simple.cnf", sdd, compiler_options=SententialDecisionDiagrams.CompilerOptions(vtree_search_mode=-1))
# For DNF functions use `read_dnf_file`

# Model Counting
wmc = SententialDecisionDiagrams.wmc_manager(root, log_mode=true)
w = SententialDecisionDiagrams.propagate(wmc)
println("Model count: $(convert(Int32,exp(w)))")

# Weighted Model Counting
lits = [SententialDecisionDiagrams.literal(i,sdd) for i in 1:SententialDecisionDiagrams.var_count(sdd)]

# Positive literal weight
SententialDecisionDiagrams.set_literal_weight(lits[1], log(0.5), wmc)
# Negative literal weight
SententialDecisionDiagrams.set_literal_weight(~lits[1], log(0.5), wmc)

w = SententialDecisionDiagrams.propagate(wmc)
println("Weighted model count: $(exp(w))")

# Visualize SententialDecisionDiagrams and VTREE
println("saving sdd and vtree ... ")
SententialDecisionDiagrams.dot("$(@__DIR__)/output/simple-vtree.dot", vtree)
SententialDecisionDiagrams.dot("$(@__DIR__)/output/simple-sdd-cnf.dot", root)
