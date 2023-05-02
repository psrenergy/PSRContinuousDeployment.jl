"""
    solve_model(a::Float64)

Solve an optimization model with rhs of the second constraint equals to `a`.
"""
function solve_model(rhs::Float64)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, x[1:2] >= 0)
    @constraint(model, 2x[1] + 1x[2] <= 4)
    @constraint(model, 1x[1] + 2x[2] <= rhs)
    @objective(model, Max, 4x[1] + 3x[2])
    optimize!(model)
    JuMP.value.(x)
    return objective_value(model)
end
