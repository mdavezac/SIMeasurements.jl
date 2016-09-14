using SIMeasurements: Meter, Kilogram, unit_symbol, dimensionality
facts("Basic SI Types") do
    @fact dimensionality(Meter) --> [1, 0, 0, 0, 0, 0, 0, 0, 0]
    @fact unit_symbol(Meter) --> "m"

    @fact dimensionality(Kilogram) --> [0, 1, 0, 0, 0, 0, 0, 0, 0]
    @fact unit_symbol(Kilogram) --> "kg"
end

facts("Unit symbols of more complicated types") do
    const Kludge = Unit{:SI, Dimensions(luminosity=-1, mass=2, length=3)}()
    @fact dimensionality(Kludge) --> [3, 2, 0, 0, 0, 0, -1, 0, 0]
    @fact unit_symbol(Kludge) --> "m³⋅kg²⋅Cd⁻¹"
end

facts("Operations over units") do
    @fact dimensionality(Meter * Meter) --> [2, 0, 0, 0, 0, 0, 0, 0, 0]
    @fact dimensionality(Meter * Kilogram) --> [1, 1, 0, 0, 0, 0, 0, 0, 0]
    @fact dimensionality(Meter / Kilogram) --> [1, -1, 0, 0, 0, 0, 0, 0, 0]
    @fact dimensionality(Meter / Meter) --> [0, 0, 0, 0, 0, 0, 0, 0, 0]

    @fact dimensionality(Meter^-1) --> [-1, 0, 0, 0, 0, 0, 0, 0, 0]
    @fact dimensionality(Meter^0) --> [0, 0, 0, 0, 0, 0, 0, 0, 0]
end
