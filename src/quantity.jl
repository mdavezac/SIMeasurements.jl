immutable Quantity{T <: Number, UNIT} <: Number
    _::T
end


""" Physical unit of the input quantity """
unit(q::Quantity) = unit(typeof(q))
unit{T <: Number, U}(q::Type{Quantity{T, U}}) = U

Base.convert(::Type{Number}, q::Quantity) = q._
Base.show(io::IO, q::Quantity) = print(io, q._, unit(q))
Base.eltype{T <: Number, U}(::Type{Quantity{T, U}}) = T
Base.eltype(q::Quantity) = eltype(typeof(q))

*(x::Number, unit::AbstractUnit) = Quantity{typeof(x), unit}(x)
*(unit::AbstractUnit, x::Number) = Quantity{typeof(x), unit}(x)
/(x::Number, unit::AbstractUnit) = Quantity{typeof(x), unit^-1}(x)
/(unit::AbstractUnit, x::Number) = Quantity{typeof(x), unit}(1/x)

dimensionality(q::Quantity) = dimensionality(unit(q))
dimensionality{T <: Number, U}(::Type{Quantity{T, U}}) = dimensionality(U)
unit_system(q::Quantity) = unit_system(unit(q))
unit_system{T <: Number, U}(::Type{Quantity{T, U}}) = unit_system(U)

""" converts quantity to given unit """
function conversion(a::Quantity, b::AbstractUnit)
    dimensionality(a) == dimensionality(b) ||
        error("Dimensionality do not match")
    unit_system(unit(a)) == unit_system(b) && return a
    const slope, offset = conversion_factors(unit(a), b)
    Quantity{eltype(a), b}(slope * a._ + offset)
end
""" converts quantity to another system """
function conversion(a::Quantity, system::Symbol)
    unit_system(a) == system && return a
    const U = Unit{system, dimensionality(a)}()
    const slope, offset = conversion_factors(unit(a), U)
    Quantity{eltype(a), U}(a._ * slope + offset)
end
""" converts quantity to another system """
function conversion(u::Unit, system::Symbol)
    unit_system(u) == system && return u
    const U = Unit{system, dimensionality(u)}()
    const slope, offset = conversion_factors(u, U)
    const value = 1 * slope + offset
    Quantity{typeof(value), U}(value)
end
