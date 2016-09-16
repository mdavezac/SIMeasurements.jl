@generated function *(a::Quantity, b::Quantity)
    if unit_system(a) ≠ unit_system(b)
        const S = prefer_system(unit_system(a), unit_system(b))
        return :(conversion(a, $S) * conversion(b, $S))
    end

    const T = promote_type(eltype(a), eltype(b))
    const S = unit_system(a)
    const D = dimensionality(a) + dimensionality(b)
    all(D .== 0) && return :(a._ * b._)
    const U = Unit{S, D}()
    return :(Quantity{$T, $U}(a._ * b._))
end

# function Base.promote_op{Ta < Number, Ua <: AbstractUnit,
#                          Tb <: Number, Ub <: AbstractUnit}
#                         (::Base.MulFun, a::Type{Quantity{Ta, Ua}},
#                          b::Type{Quantity{Tb, Ub}})
#     Quantity{promote_type(Ta, Tb), Ua * Ub}
# end
# for op in (:*, :/)
#     @eval begin
#         function $op{T <: Number, D <: Unit}(a::Quantity{T, D}, b::Quantity{T, D})
#             const value = $op(a._, b._)
#             return Quantity{typeof(value), typeof($op(unit(a), unit(b)))}(value)
#         end
#         # function $op{T0 <: Number, T1 <: Number, D}(a::Quantity{T0, D}, b::Quantity{T, D})
#         #     const S = prefer_system(unit_symbol(a), unit_system(b))
#         #     $op(conversion(a, S), conversion(b, S))
#         # end
#     end
# end
