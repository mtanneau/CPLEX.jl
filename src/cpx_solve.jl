function solve_lp!(prob::CPXproblem)
    ret = @cpx_ccall(lpopt, Cint, (Ptr{Void}, Ptr{Void}), prob.env.ptr, prob.lp)
    if ret != 0
        error("CPLEX: Error solving LP")
    end
end

function get_solution(prob::CPXproblem)
    obj = [0.0]
    x   = Array(Float64, prob.nvars)
    status = Array(Cint, 1)
    ret = @cpx_ccall(solution,
                     Cint,
                     (Ptr{Void}, Ptr{Void}, Ptr{Cint}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}),
                     prob.env.ptr,
                     prob.lp,
                     status,
                     obj,
                     x,
                     C_NULL,
                     C_NULL,
                     C_NULL)
    if ret != 0
       error("CPLEX: Error getting solution")
   end
   return(obj[1], x)
end

const status_symbols = [
    1   => :CPX_STAT_OPTIMAL,
    2   => :CPX_STAT_UNBOUNDED,
    3   => :CPX_STAT_INFEASIBLE,
    4   => :CPX_STAT_INForUNBD,
    5   => :CPX_STAT_OPTIMAL_INFEAS,
    6   => :CPX_STAT_NUM_BEST,
    7   => :CPX_STAT_FEASIBLE_RELAXED,
    8   => :CPX_STAT_OPTIMAL_RELAXED,
    10  => :CPX_STAT_ABORT_IT_LIM,
    11  => :CPX_STAT_ABORT_TIME_LIM,
    11  => :CPX_STAT_ABORT_OBJ_LIM,
    13  => :CPX_STAT_ABORT_USER,
    20  => :CPX_STAT_OPTIMAL_FACE_UNBOUNDED,
    21  => :CPX_STAT_ABORT_PRIM_OBJ_LIM,
    22  => :CPX_STAT_ABORT_DUAL_OBJ_LIM,
    101 => :CPXMIP_OPTIMAL,
    102 => :CPXMIP_OPTIMAL_TOL,
    103 => :CPXMIP_INFEASIBLE,
    104 => :CPXMIP_SOL_LIM,
    105 => :CPXMIP_NODE_LIM_FEAS,
    106 => :CPXMIP_NODE_LIM_INFEAS,
    107 => :CPXMIP_TIME_LIM_FEAS,
    108 => :CPXMIP_TIME_LIM_INFEAS,
    109 => :CPXMIP_FAIL_FEAS,
    110 => :CPXMIP_FAIL_INFEAS,
    111 => :CPXMIP_MEM_LIM_FEAS,
    112 => :CPXMIP_MEM_LIM_INFEAS,
    113 => :CPXMIP_ABORT_FEAS,
    114 => :CPXMIP_ABORT_INFEAS,
    115 => :CPXMIP_OPTIMAL_INFEAS,
    116 => :CPXMIP_FAIL_FEAS_NO_TREE,
    117 => :CPXMIP_FAIL_INFEAS_NO_TREE,
    118 => :CPXMIP_UNBOUNDED,
    119 => :CPXMIP_INForUNBD,
    120 => :CPXMIP_FEASIBLE_RELAXED,
    121 => :CPXMIP_OPTIMAL_RELAXED
]

get_status(model::CPXproblem) = status_symbols[int(get_status_code(model))]::Symbol
get_status_code(model::CPXproblem) = @cpx_ccall(getstat, Cint, (Ptr{Void}, Ptr{Void}), model.env.ptr, model.lp)