module SIMeasurements

export Dimensions, Unit, Quantity, unit, conversion

using FixedSizeArrays: FixedVectorNoTuple
import Base: *, ^, /, //

include("units.jl")
include("quantity.jl")
include("quantity_ops.jl")
end # module
