""" Dimensionlity descriptor """
immutable Dimensions{T <: Real} <: FixedVectorNoTuple{9, T}
    length::T
    mass::T
    time::T
    current::T
    temperature::T
    quantity::T
    luminosity::T
    angle::T
    solid_angle::T
end
function Dimensions{T <: Real}(;length::T=0, mass::T=0, time::T=0,
    current::T=0, temperature::T=0, quantity::T=0,
    luminosity::T=0, angle::T=0, solid_angle::T=0)
    Dimensions{T}(length, mass, time, current, temperature, quantity,
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
""" Dimensionality of the unit """
dimensionality(unit::AbstractUnit) = typeof(unit).parameters[2]
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
    error("Unexpected Chatacter")
end

function unit_symbol(unit::AbstractUnit)
    const system = unit_system(unit)
    const T = eltype(dimensionality(unit))
    const iters = 1:length(dimensionality(unit)), dimensionality(unit)
    const nonzero = filter(zip(iters...)) do dim
        dim[2] != 0
    end
    const strings = map(nonzero) do dim
        const args = vcat(zeros(T, dim[1] - 1), T[1], zeros(T, 9 - dim[1]))
        const pure = Unit{system, Dimensions{T}(args...)}()
        "$(unit_symbol(pure))$(superscript(dim[2]))"
    end
    join(strings, "⋅")
end

function prefer_system(a::AbstractUnit, b::AbstractUnit)
    if unit_system(a) == :SI || unit_system(b) == :SI
        :SI
    else
        unit_system(a)
    end
end

function *(a::AbstractUnit, b::AbstractUnit)
    const dims = dimensionality(a) + dimensionality(b)
    all(dims .== 0) && return T
    const system = prefer_system(a, b)
    Unit{system, Dimensions(dimensionality(a) + dimensionality(b))}()
end

function /(a::AbstractUnit, b::AbstractUnit)
    const dims = dimensionality(a) - dimensionality(b)
    all(dims .== 0) && return 1
    const system = prefer_system(a, b)
    Unit{system, Dimensions(dimensionality(a) - dimensionality(b))}()
end
function ^(a::AbstractUnit, p::Integer)
    p == 0 && return 1
    Unit{unit_system(a), dimensionality(a) * p}()
end
function ^(a::AbstractUnit, p::Real)
    abs(p) < 1e-12 && return 1
    Unit{unit_system(a), dimensionality(a) * p}()
end

function Base.show(io::IO, unit::Unit)
    print(io, "$(unit_system(unit))($(unit_symbol(unit)))")
end
