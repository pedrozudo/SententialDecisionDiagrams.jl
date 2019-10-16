module NormalForm

include("sddapi.jl")

using .SddLibrary

struct VTree_c end
mutable struct LitSet
    id::SddLibrary.SddSize
    literal_count::SddLibrary.SddLiteral
    literals::Array{SddLibrary.SddLiteral}
    op::SddLibrary.BoolOp
    vtree::VTree_c
    bit::UInt8
    LitSet() = new()
end
mutable struct Fnf
    var_count::SddLibrary.SddLiteral
    litset_count::SddLibrary.SddSize
    litsets::Array{LitSet}
    op::SddLibrary.BoolOp
end


function read_cnf(filename::String)::Fnf
    return parse_fnf(filename,  convert(SddLibrary.BoolOp,0))
end
function read_dnf(filename::String)::Fnf
    return parse_fnf(filename, convert(SddLibrary.BoolOp,1))
end

function parse_fnf(filename::String, op::SddLibrary.BoolOp)::Fnf
    f = open(filename)
    lines  = readlines(f)
    close(f)

    id::SddLibrary.SddSize = 0
    var_count::SddLibrary.SddLiteral = 0
    litset_count::SddLibrary.SddSize = 0

    n_extra_lines = 0
    for l in lines
        l_split = split(l)
        n_extra_lines += 1
        if l_split[1]=="c"
            continue
        elseif l_split[1]=="p"
            if op==0 @assert(l_split[2]=="cnf") else @assert(l_split[2]=="dnf") end
            var_count = parse(SddLibrary.SddLiteral, l_split[3])
            litset_count = parse(SddLibrary.SddSize, l_split[4])
            break
        end
    end

    fnf = Fnf(var_count, litset_count, Array{LitSet}[], op)


    for c in lines[n_extra_lines+1:end]
        terms = split(c)
        for t in terms
            if t=="0" break end
            lit = parse(SddLibrary.SddLiteral, t)
            println(t)
        end
        println(clause)
    # for k in lines
    #     k_split = split(k)
    #     if (k_split[1]=="c") | (k_split[1]=="p") continue end
    #     @assert(k_split[length(k_split)]=="0")
    #     println(k)
    # end
    end


    exit()
end










  # // read in clauses
  # // assume longest possible clause is #-vars * 2
  # LitSet* clause;
  # SddLiteral* temp_clause = (SddLiteral*)calloc(cnf->var_count*2,sizeof(SddLiteral));
  # SddLiteral lit;
  # SddLiteral lit_index;
  # for(SddSize clause_index = 0; clause_index < cnf->litset_count; clause_index++) {
  #   lit_index = 0;
  #   while (1) { // read a clause
  #     lit = cnf_int_strtok();
  #     if (lit == 0) break;
  #     test_parse_fnf_file(lit_index >= cnf->var_count*2,
  #                         "Unexpected long clause.");
  #     temp_clause[lit_index] = lit;
  #     lit_index++;
  #   }
  #   clause = &(cnf->litsets[clause_index]);
  #   clause->id = id++;
  #   clause->bit = 0;
  #   clause->literal_count = lit_index;
  #   clause->literals = (SddLiteral*)calloc(clause->literal_count,sizeof(SddLiteral));
  #   for(lit_index = 0; lit_index < clause->literal_count; lit_index++)
  #     clause->literals[lit_index] = temp_clause[lit_index];
  # }




# void free_fnf(Fnf* fnf);
#
# SddNode* fnf_to_sdd(Fnf* fnf, SddManager* manager);
#
# /****************************************************************************************
#  * forward references
#  ****************************************************************************************/
#
# void sort_litsets_by_lca(LitSet** litsets, SddSize litset_count, SddManager* manager);




end
