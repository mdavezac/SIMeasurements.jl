module SIMeasurements

export Dimensions, Unit, Quantity

using FixedSizeArrays: FixedVectorNoTuple
import Base: *, ^, /

include("units.jl")
# immutable Quantity{T <: Number, UNIT <: AbstractUnit}
#     _::T
# end

# *(x::Real, unit::AbstractUnit) = Quantity{typeof(x), typeof(unit)}(x)

# """ Units of the given quantity """
# units(q::Quantity) = typeof(q).parameters[1]()
#
# function Base.show(io::IO, units::Quantity)
#     nonzero = typeof(Quantity).parameters
#     typeof(unit).parameters[1]
# end

end # module
