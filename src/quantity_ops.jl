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

@generated function /(a::Quantity, b::Quantity)
    if unit_system(a) ≠ unit_system(b)
        const S = prefer_system(unit_system(a), unit_system(b))
        const qa = conversion(unit(a), S)
        const qb = conversion(unit(a), S)
        return :(conversion(a, $S) / conversion(b, $S))
    end

    const T = promote_type(eltype(a), eltype(b))
    const S = unit_system(a)
    const D = dimensionality(a) - dimensionality(b)
    all(D .== 0) && return :(a._ / b._)
    const U = Unit{S, D}()
    return :(Quantity{$T, $U}(a._ / b._))
end

@generated function //(a::Quantity, b::Quantity)
    if unit_system(a) ≠ unit_system(b)
        const S = prefer_system(unit_system(a), unit_system(b))
        const qa = conversion(unit(a), S)
        const qb = conversion(unit(a), S)
        return :(conversion(a, $S) // conversion(b, $S))
    end

    const T = Base.promote_op(//, eltype(a), eltype(b))
    const S = unit_system(a)
    const D = dimensionality(a) - dimensionality(b)
    all(D .== 0) && return :(a._ // b._)
    const U = Unit{S, D}()
    return :(Quantity{Rational{$T}, $U}(a._ // b._))
end
