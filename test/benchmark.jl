module SIMeasurementsBenchmark
using DataFrames
using BenchmarkTools
using SIMeasurements: Meter, Kilogram, Unit, Dimensions
import SIMeasurements: conversion_factors

const Klurdge = Unit{:Koala, Dimensions(length=2)}()
conversion_factors(
    ::Unit{:Koala, Dimensions(length=1)}, ::typeof(Meter)) = 1//2, 0

suite = BenchmarkGroup()
suite[:scalar] = BenchmarkGroup(["scalar"])
suite[:array] = BenchmarkGroup(["array"])
suite[:scalar][:same] = BenchmarkGroup(["same units"])
for op in (:*, :/, ://)
    suite[:scalar][op] = BenchmarkGroup([string(op)])
    suite[:scalar][op][:nothing] =
        @benchmarkable $op($(rand(1:10)), $(rand(1:10)))
    suite[:scalar][op][:same] =
        @benchmarkable $op($(rand(1:10)Meter), $(rand(1:10)Meter))
    suite[:scalar][op][:different] =
        @benchmarkable $op($(rand(1:10)Meter), $(rand(1:10)Kilogram))
    suite[:scalar][op][:inv] =
        @benchmarkable $op($(rand(1:10)Meter), $(rand(1:10)Meter^-1))
    suite[:scalar][op][:systems] =
        @benchmarkable $op($(rand(1:10)Klurdge), $(rand(1:10)Meter^-1))
end

for op in (:+, :-)
    suite[:scalar][op] = BenchmarkGroup([string(op)])
    suite[:scalar][op][:nothing] =
        @benchmarkable $op($(rand(1:10)), $(rand(1:10)))
    suite[:scalar][op][:same] =
        @benchmarkable $op($(rand(1:10)Meter), $(rand(1:10)Meter))
    suite[:scalar][op][:systems] =
        @benchmarkable $op($(rand(1:10)Klurdge), $(rand(1:10)Meter^2))
end

tune!(suite)
results = run(suite)
for op in keys(suite[:scalar])
    for key in keys(suite[:scalar][op])
        key == :nothing && continue
        bench = results[:scalar][op]
        print(op, ", ", key, " ")
        println(ratio(median(bench[key]), median(bench[:nothing])))
    end
end

end
