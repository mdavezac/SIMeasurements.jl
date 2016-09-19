@generated function *(a::Quantity, b::Quantity)
    if unit_system(a) ≠ unit_system(b)
        const S = string(prefer_system(unit(a), unit(b)))
        return :(conversion(a, Symbol($S)) * conversion(b, Symbol($S)))
    end
    dimensionality(a) == -dimensionality(b) && return :(a._ * b._)
    const T = promote_type(eltype(a), eltype(b))
    const U = Unit{unit_system(a), dimensionality(a) + dimensionality(b)}
    :(Quantity{$T, $U}(a._ * b._))
end

@generated function /(a::Quantity, b::Quantity)
    if unit_system(a) ≠ unit_system(b)
        const S = string(prefer_system(unit(a), unit(b)))
        return :(conversion(a, Symbol($S)) / conversion(b, Symbol($S)))
    end
    dimensionality(a) == dimensionality(b) && return :(a._ / b._)
    const T = promote_type(eltype(a), eltype(b))
    const U = Unit{unit_system(a), dimensionality(a) - dimensionality(b)}
    :(Quantity{$T, $U}(a._ / b._))
end

@generated function //(a::Quantity, b::Quantity)
    if unit_system(a) ≠ unit_system(b)
        const S = string(prefer_system(unit(a), unit(b)))
        return :(conversion(a, Symbol($S)) // conversion(b, Symbol($S)))
    end
    dimensionality(a) == dimensionality(b) && return :(a._ // b._)
    const T = typeof(one(eltype(a)) // one(eltype(b)))
    const U = Unit{unit_system(a), dimensionality(a) - dimensionality(b)}
    :(Quantity{$T, $U}(a._ // b._))
end

*(n::Bool, q::Quantity) = n ? (1 * q): (0 * q)
@generated function *(n::Number, q::Quantity)
    :(Quantity{$(promote_type(n, eltype(q))), $(typeof(unit(q)))}(q._ * n))
end
*(q::Quantity, n::Number) = n * q
@generated function /(n::Number, q::Quantity)
    const U = Unit{unit_system(q), -dimensionality(q)}
    :(Quantity{$(promote_type(n, eltype(q))), $U}(n / q._))
end
@generated function /(q::Quantity, n::Number)
    :(Quantity{$(promote_type(n, eltype(q))), $(typeof(unit(q)))}(q._ / n))
end
@generated function //(n::Number, q::Quantity)
    const U = Unit{unit_system(q), -dimensionality(q)}
    const T = typeof(one(n) // one(eltype(q)))
    :(Quantity{$T, $U}(n // q._))
end
@generated function //(q::Quantity, n::Complex)
    const T = typeof(one(eltype(q)) // one(n))
    :(Quantity{$T, $(typeof(unit(q)))}(q._ // n))
end
@generated function //(q::Quantity, n::Number)
    const T = typeof(one(eltype(q)) // one(n))
    :(Quantity{$T, $(typeof(unit(q)))}(q._ // n))
end

@generated function *(n::Unit, q::Quantity)
    if unit_system(n) ≠ unit_system(q)
        const S = prefer_system(n, unit(q))
        :(conversion(1n, $S) * conversion(q, $S))
    end
    dimensionality(n) == -dimensionality(q) && return q._
    const U = Unit{unit_system(n), dimensionality(n) + dimensionality(q)}
    :(Quantity{$(eltype(q)), $U}(q._))
end
*(q::Quantity, n::Unit) = n * q
@generated function /(n::Unit, q::Quantity)
    if unit_system(n) ≠ unit_system(q)
        const S = prefer_system(n, unit(q))
        :(conversion(1n, $S) / conversion(q, $S))
    end
    dimensionality(n) == dimensionality(q) && return 1/q._
    const U = Unit{unit_system(n), dimensionality(n) - dimensionality(q)}
    :(Quantity{$(eltype(q)), $U}(1/q._))
end
@generated function /(q::Quantity, n::Unit)
    if unit_system(n) ≠ unit_system(q)
        const S = prefer_system(n, unit(q))
        :(conversion(q, $S) / conversion(1n, $S))
    end
    dimensionality(n) == dimensionality(q) && return q._
    const U = Unit{unit_system(n), dimensionality(q) - dimensionality(n)}
    :(Quantity{$(eltype(q)), $U}(q._))
end
@generated function //(n::Unit, q::Quantity)
    if unit_system(n) ≠ unit_system(q)
        const S = prefer_system(n, unit(q))
        :(conversion(1n, $S) // conversion(q, $S))
    end
    dimensionality(n) == dimensionality(q) && return 1//q._
    const U = Unit{unit_system(n), dimensionality(n) - dimensionality(q)}
    :(Quantity{$(eltype(q)), $U}(1//q._))
end
//(q::Quantity, n::Unit) = n / q

@generated function Base.promote_rule{Ta <: Number, Tb <: Number, Sa, Sb, D}(
           ::Type{Quantity{Ta, Unit{Sa, D}}}, ::Type{Quantity{Tb, Unit{Sb, D}}})
    const S = prefer_system(Unit{Sa, D}(), Unit{Sb, D}())
    :(Quantity{$(promote_type(Ta, Tb)), $(Unit{S, D})})
end

# Conversion to itself
Base.convert{T <: Number, U <: Unit}(
                                  ::Type{Quantity{T, U}}, q::Quantity{T, U}) = q
# Conversion from same system
Base.convert{Ta <: Number, Tb <: Number, U <: Unit}(
                                  ::Type{Quantity{Ta, U}}, q::Quantity{Tb, U}) =
    Quantity{promote_type(Ta, Tb), U}(convert(promote_type(Ta, Tb), q._))

# Conversion from different systems
function Base.convert{Ta <: Number, Tb <: Number, Sa, Sb, D}(
                ::Type{Quantity{Ta, Unit{Sa, D}}}, q::Quantity{Tb, Unit{Sb, D}})
    const T = promote_type(Ta, Tb)
    const value = convert(T, q._)
    result = conversion(Quantity{T, Unit{Sb, D}}(value), Sa)
    Quantity{Ta, Unit{Sa, D}}(convert(Ta, result._))
end

@generated function Base.isless(a::Quantity, b::Quantity)
    dimensionality(a) ≠ dimensionality(b) && error("Incompatible units")
    unit_system(a) ≠ unit_system(b) &&
        :(isless(a, conversion(b, unit_system(a))))
    :(isless(a._, b._))
end
