using SIMeasurements: Quantity, Dimensions, unit_system

facts("Creating a quantity") do
    @fact unit(2Meter) --> exactly(Meter)
    @fact convert(Number, 2Meter) --> 2
    @fact typeof(2Meter) --> is_subtype(Quantity)
end

const klurdge = Unit{:Koala, Dimensions(length=2)}()
conversion_factors(::Unit{:Koala, Dimensions(length=1)}, ::typeof(Meter)) =
    1//2, 0

facts("Simple conversion") do
    @fact unit_system(1.5 * klurdge) --> :Koala
    @fact conversion(1.5 * klurdge, Meter^2) --> 1.5 * 1//4 * Meter^2

    @fact conversion(1.5 * klurdge, :SI) --> 1.5 * 1//4 * Meter^2
    @fact conversion(klurdge, :Koala) --> exactly(klurdge)
    const value = 1.5 * klurdge
    @fact conversion(value, :Koala) --> exactly(value)
end

facts("Operations") do
    @fact unit_system((2 * Meter) * (3 * Kilogram)) --> :SI
    @fact dimensionality((2 * Meter) * (3 * Kilogram)) -->
        Dimensions(length=1, mass=1)
    @fact eltype((2 * Meter) * (3 * Kilogram)) --> typeof(6)
    @fact (2 * Meter) * (3 * Kilogram) -->
        6 * Unit{:SI, Dimensions(length=1, mass=1)}()

    @fact eltype((2 * Meter) * (3.5 * Kilogram)) --> typeof(7.0)
    @fact (2 * Meter) * (3.5 * Kilogram) -->
        7.0 * Unit{:SI, Dimensions(length=1, mass=1)}()
end
