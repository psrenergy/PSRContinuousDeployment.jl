@testset "Teste modelo 1" begin
    @test PSRExample.solve_model(2.0) ≈ 8.0
    @test PSRExample.solve_model(3.0) ≈ 8.66666 atol = 1e-3
    @test PSRExample.solve_model(4.0) ≈ 9.33333 atol = 1e-3
end
