using SIMeasurements: Meter, Kilogram, unit_symbol, dimensionality
import SIMeasurements: conversion_factors
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
    @fact typeof(dimensionality(Meter * Meter)) --> exactly(Dimensions)
    @fact dimensionality(Meter * Kilogram) --> [1, 1, 0, 0, 0, 0, 0, 0, 0]
    @fact typeof(dimensionality(Meter * Kilogram)) --> exactly(Dimensions)
    @fact dimensionality(Meter / Kilogram) --> [1, -1, 0, 0, 0, 0, 0, 0, 0]
    @fact typeof(dimensionality(Meter / Kilogram)) --> exactly(Dimensions)
    @fact dimensionality(Meter / Meter) --> [0, 0, 0, 0, 0, 0, 0, 0, 0]
    @fact typeof(dimensionality(Meter / Meter)) --> exactly(Dimensions)

    @fact dimensionality(Meter^-1) --> [-1, 0, 0, 0, 0, 0, 0, 0, 0]
    @fact typeof(dimensionality(Meter^-1)) --> exactly(Dimensions)
    @fact dimensionality(Meter^0) --> [0, 0, 0, 0, 0, 0, 0, 0, 0]
    @fact typeof(dimensionality(Meter^0)) --> exactly(Dimensions)
end

const Kloodge = Unit{:Beware, Dimensions(length=1)}()
conversion_factors(::typeof(Kloodge), ::typeof(Meter)) = 3//10, 3//5
const Blagger = Unit{:Beware, Dimensions(mass=2)}()
conversion_factors(::Unit{:Beware, Dimensions(mass=1)}, ::typeof(Kilogram)) =
    2//3, 0
facts("Conversion factor") do
   @fact conversion_factors(Kloodge, Meter) --> (3//10, 3//5)
   @fact conversion_factors(Meter, Kloodge) --> (10//3, -2)
   @fact conversion_factors(Meter^2, Kloodge^2) --> (100//9, 0)
   @fact conversion_factors(Blagger, Kilogram^2) --> (4//9, 0)
end
