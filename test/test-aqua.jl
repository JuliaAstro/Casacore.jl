@testset "Aqua" begin
    using Casacore, Aqua
    Aqua.test_all(Casacore; ambiguities = false)
end
