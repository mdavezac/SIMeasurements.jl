""" Dimensionlity descriptor """
immutable Dimensions <: FixedVectorNoTuple{9, Rational{Int64}}
    length::Rational{Int64}
    mass::Rational{Int64}
    time::Rational{Int64}
    current::Rational{Int64}
    temperature::Rational{Int64}
    quantity::Rational{Int64}
    luminosity::Rational{Int64}
    angle::Rational{Int64}
    solid_angle::Rational{Int64}
end
function Dimensions(;length::Real=0, mass::Real=0, time::Real=0,
    current::Real=0, temperature::Real=0, quantity::Real=0,
    luminosity::Real=0, angle::Real=0, solid_angle::Real=0)
    Dimensions(length, mass, time, current, temperature, quantity,
        luminosity, angle, solid_angle)
end

""" Abstract unit dimension """
abstract AbstractUnit{SYSTEM, DIMENSIONS}
""" Static unit type """
immutable Unit{SYSTEM, DIMENSIONS} <: AbstractUnit{SYSTEM, DIMENSIONS}; end

const si_names = [:Meter, :Kilogram, :Second, :Ampere, :Kelvin, :Mol,
                  :Candela, :Radian, :Steradian]
const si_symbols = [:m, :kg, :s, :A, :K, :mol, :Cd, :rad, :sr]
for (name, dim, symb) in zip(si_names, fieldnames(Dimensions), si_symbols)
    const str = string(symb)
    @eval begin
        const $name = Unit{:SI, Dimensions($dim=1)}()
        unit_symbol(::Unit{:SI, Dimensions($dim=1)}) = $str
    end
end

""" System of which this is a unit """
unit_system(unit::AbstractUnit) = typeof(unit).parameters[1]
unit_system{S, D}(::Type{Unit{S, D}}) = S
""" Dimensionality of the unit """
dimensionality{S, D}(::Type{Unit{S, D}}) = D
dimensionality(unit::AbstractUnit) = dimensionality(typeof(unit))
dimensionality(x::Real) = Dimensions()

""" Prints superscript """
superscript(i) = map(repr(i)) do c
    c   ==  '-' ? '\u207b' :
    c   ==  '1' ? '\u00b9' :
    c   ==  '2' ? '\u00b2' :
    c   ==  '3' ? '\u00b3' :
    c   ==  '4' ? '\u2074' :
    c   ==  '5' ? '\u2075' :
    c   ==  '6' ? '\u2076' :
    c   ==  '7' ? '\u2077' :
    c   ==  '8' ? '\u2078' :
    c   ==  '9' ? '\u2079' :
    c   ==  '0' ? '\u2070' :
    c   ==  '/' ? '\u2032' :
    c   ==  '.' ? '\u2027' :
    error("Unexpected Character $c")
end

function unit_symbol(unit::AbstractUnit)
    sum(dimensionality(unit)) == 1 &&
        return "$(unit_system(unit)): $(dimensionality(unit))"
    const system = unit_system(unit)
    const iters = 1:length(dimensionality(unit)), dimensionality(unit)
    const nonzero = filter(zip(iters...)) do dim
        dim[2] != 0
    end
    const strings = map(nonzero) do dim
        const args = vcat(
            zeros(Int16, dim[1] - 1), Int16[1], zeros(Int16, 9 - dim[1]))
        const pure = Unit{system, Dimensions(args...)}()
        if dim[2] == 0
            "$(unit_symbol(pure))"
        elseif dim[2].den == 1
            "$(unit_symbol(pure))" * superscript(dim[2].num)
        else
            "$(unit_symbol(pure))" * superscript(dim[2])
        end
    end
    join(strings, "⋅")
end

function prefer_system(a::AbstractUnit, b::AbstractUnit)
    (unit_system(a) == :SI || unit_system(b) == :SI) && return :SI
    unit_system(a)
end

function *(a::Unit, b::Unit)
    const dims = dimensionality(a) + dimensionality(b)
    all(dims .== 0) && return 1
    const system = prefer_system(a, b)
    Unit{system, dimensionality(a) + dimensionality(b)}()
end

function /(a::Unit, b::Unit)
    const dims = dimensionality(a) - dimensionality(b)
    all(dims .== 0) && return 1
    const system = prefer_system(a, b)
    Unit{system, dimensionality(a) - dimensionality(b)}()
end
function ^(a::Unit, p::Integer)
    p == 0 && return 1
    Unit{unit_system(a), dimensionality(a) * p}()
end
function ^(a::Unit, p::Rational)
    abs(p) < 1e-12 && return 1
    Unit{unit_system(a), dimensionality(a) * p}()
end

typealias UseRational Union{Integer, Rational}
invert_conversion(a::UseRational, b::UseRational) = 1//a, b == 0 ? 0: -b//a
invert_conversion(a::UseRational, b::Real) = 1//a, -b/a
invert_conversion(a::Real, b::Real) = 1/a, -b/a
""" Conversion factors from a to b """
function conversion_factors(a::Unit, b::Unit)
    a ≡ b && return (1, 0)
    dimensionality(a) == dimensionality(b) || error("Incompatible units")
    if unit_system(b) == :SI
        sum(dimensionality(a)) == 1 &&
            error("Missing conversion factor for instance of $(typeof(a))")
        mapreduce(*, enumerate(dimensionality(a))) do dims
                dims[2] == 0 && return 1
                args = zeros(Int64, 9)
                args[dims[1]] = 1
                const dimensions = Dimensions(args...)
                const Da = Unit{unit_system(a), dimensions}()
                const Db = Unit{:SI, dimensions}()
                if dims[2].den == 1
                    conversion_factors(Da, Db)[1]^dims[2].num
                else
                    conversion_factors(Da, Db)[1]^dims[2]
                end
        end, 0
    elseif unit_system(a) == :SI
        invert_conversion(conversion_factors(b, a)...)
    elseif sum(dimensionality(a)) == 1
        const a_slope, a_offset =
            conversion_factors(a, Unit{:SI, dimensionality(a)}())
        const b_slope, b_offset =
            conversion_factors(Unit{:SI, dimensionality(a)}(), b)
        a_slope * b_slope, a_offset * b_slope + b_offset
    else
        const a_slope = conversion_factors(a, Unit{:SI, dimensionality(a)}())[1]
        const b_slope = conversion_factors(Unit{:SI, dimensionality(a)}(), b)[1]
        a_slope * b_slope, 0
    end
end

function Base.show(io::IO, unit::Unit)
    print(io, "$(unit_symbol(unit))[$(unit_system(unit))]")
end
