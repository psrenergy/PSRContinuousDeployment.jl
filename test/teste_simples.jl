@testset "teste simples" begin
    @test 1 + 1 == 2
    @test 2 / 3 ≈ 0.6666 atol = 1e-3
    @test_throws ErrorException error("testando erro.")
end
