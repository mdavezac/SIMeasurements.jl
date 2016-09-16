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
end
