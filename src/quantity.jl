immutable Quantity{T <: Number, UNIT <: AbstractUnit}
    _::T
end


""" Physical unit of the input quantity """
unit(q::Quantity) = typeof(q).parameters[2]()

Base.convert(::Type{Number}, q::Quantity) = q._
Base.show(io::IO, q::Quantity) = print(io, q._, unit(q))
Base.eltype(q::Quantity) = typeof(q).parameters[1]

*(x::Number, unit::AbstractUnit) = Quantity{typeof(x), typeof(unit)}(x)
*(unit::AbstractUnit, x::Number) = Quantity{typeof(x), typeof(unit)}(x)
/(x::Number, unit::AbstractUnit) = Quantity{typeof(x), typeof(unit^-1)}(x)
/(unit::AbstractUnit, x::Number) = Quantity{typeof(x), typeof(unit)}(1/x)

dimensionality(q::Quantity) = dimensionality(unit(q))
unit_system(q::Quantity) = unit_system(unit(q))
""" converts quantity to given unit """
function conversion(a::Quantity, b::AbstractUnit)
    dimensionality(a) == dimensionality(b) ||
        error("Dimensionality do not match")
    unit_system(unit(a)) == unit_system(b) && return a
    const slope, offset = conversion_factors(unit(a), b)
    Quantity{eltype(a), typeof(b)}(slope * a._ + offset)
end
# function *(a::Quantity, b::Quantity)
#     if dimensionality(a) == dimensionality(b)
#     end
#     const T = promote_type(eltype(a), eltype(b),
#     const U = typeof(unit(a) * unit(b))
#     Quantity{T, U}(a._, b._)
# end
