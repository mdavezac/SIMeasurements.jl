using SIMeasurements: Quantity, Dimensions, unit_system
import SIMeasurements: conversion_factors

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
    context("multiplication") do
        @fact unit_system((2 * Meter) * (3 * Kilogram)) --> :SI
        @fact dimensionality((2 * Meter) * (3 * Kilogram)) -->
        Dimensions(length=1, mass=1)
        @fact eltype((2 * Meter) * (3 * Kilogram)) --> typeof(6)
        @fact (2 * Meter) * (3 * Kilogram) -->
            6 * Unit{:SI, Dimensions(length=1, mass=1)}()

        @fact eltype((2 * Meter) * (3.5 * Kilogram)) --> typeof(7.0)
        @fact (2 * Meter) * (3.5 * Kilogram) -->
            7.0 * Unit{:SI, Dimensions(length=1, mass=1)}()

        @fact 2 * Meter * 3.5 * Kilogram * 4 -->
            28 * Unit{:SI, Dimensions(length=1, mass=1)}()
        @fact 2 * (1Meter) * 3.5 * (1Kilogram) * 4 -->
            28 * Unit{:SI, Dimensions(length=1, mass=1)}()

        @fact (1klurdge) * 2 --> 2 * klurdge

        @fact klurdge/2 --> 0.5klurdge

        const actual = (1klurdge) * (3//2 * Kilogram)
        @fact unit_system(actual) --> :SI
        @fact actual --> 3//8 * Meter^2 * Kilogram
    end

    context("division") do
        @fact (4 * Meter) / (2 * Kilogram) -->
            2* Unit{:SI, Dimensions(length=1, mass=-1)}()
        @fact (2 * Meter) / (3.0 * Kilogram) -->
            (2 / 3.0) * Unit{:SI, Dimensions(length=1, mass=-1)}()
        @fact (2 * Meter) // (3 * Kilogram) -->
            (2 // 3) * Unit{:SI, Dimensions(length=1, mass=-1)}()
        @fact 2  // (3 * Kilogram) -->
            (2 // 3) * Unit{:SI, Dimensions(mass=-1)}()
        @fact 2  / (3.0 * Kilogram) -->
            (2 / 3.0) * Unit{:SI, Dimensions(mass=-1)}()

        @fact (1klurdge) / 2 --> 0.5 * klurdge
        @fact (1klurdge) // 2 --> 1//2 * klurdge
        const actual = (1klurdge) // (3//2 * Kilogram)
        @fact unit_system(actual) --> :SI
        @fact actual --> 1//4 * 2//3 * (Meter^2 / Kilogram)
        @fact actual --> (1//4 * 2//3 * Meter^2) / Kilogram
    end

    context("power") do
        @fact (1.5Meter)^-1 --> (1/1.5 * Meter^-1)
        @fact (2Meter)^(-1//2) --> (1/√2 * Meter^(-1//2))
    end

    context("comparison") do
        @fact 1Meter == (1//1) * Meter --> true
        @fact 1Meter == (2//1) * Meter --> false
        @fact 1Meter ≠ (2//1) * Meter --> true
        @fact 1Meter ≠ (1//1) * Meter --> false
        @fact 1Meter ≥ (1//1) * Meter --> true
        @fact 1Meter > (1//1) * Meter --> false
        @fact 1Meter ≤ (1//1) * Meter --> true
        @fact 1Meter < (1//1) * Meter --> false
        @fact 1Meter < (2//1) * Meter --> true
    end
end

facts("Arrays") do
    context("Create and multiply") do
        @fact typeof([1, 1]klurdge) -->
            exactly(Vector{Quantity{Int64, typeof(klurdge)}})
        @fact [2, 1]klurdge --> Quantity{Int64, typeof(klurdge)}[2, 1]
        @fact [2, 1] * (1klurdge) --> Quantity{Int64, typeof(klurdge)}[2, 1]
        @fact [2, 1] * (3klurdge) --> Quantity{Int64, typeof(klurdge)}[6, 3]
        @fact ([2, 1] * (3klurdge)) * klurdge -->
            Quantity{Int64, typeof(klurdge^2)}[6, 3]
        @fact ([2, 1] * (3klurdge)) * (1klurdge) -->
            Quantity{Int64, typeof(klurdge^2)}[6, 3]
        @fact ([2, 1] * (3klurdge)) * Meter^-2 --> [3//2, 3//4] 
        @fact ([2, 1] * (3klurdge)) * (4Meter^-2) --> [6, 3] 
        @fact ([2, 1] * (3klurdge)) * (2Meter^-3) -->
            Quantity{Rational{Int64}, typeof(Meter^-1)}[3, 3//2]
    end

    context("Create and divide") do
        @fact typeof([1, 1]/klurdge) -->
            exactly(Vector{Quantity{Int64, typeof(klurdge^-1)}})
        @fact [2, 1] / klurdge --> Quantity{Int64, typeof(klurdge^-1)}[2, 1]

        @fact [2, 1] / (1klurdge) --> Quantity{Int64, typeof(klurdge^-1)}[2, 1]
        @fact [2, 1] / (1.0klurdge) --> Quantity{Float64, typeof(klurdge^-1)}[2, 1]

        @fact (1klurdge) ./ [2, 1] --> Quantity{Float64, typeof(klurdge)}[0.5, 1.0]
        @fact (1klurdge) .// [2, 1] -->
            Quantity{Rational{Int64}, typeof(klurdge)}[1//2, 1]
    end
end
