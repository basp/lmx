import unittest, math, lmx

suite "transformations":
    test "multiplying by a translation matrix":
        let 
            t = translation(5, -3, 2)
            p = point(-3, 4, 5)
        check(t * p =~ point(2, 1, 7))
        
    test "multiplying by the inverse of a translation matrix":
        let
            t = translation(5, -3, 2)
            inv = inverse(t)
            p = point(-3, 4, 5)
        check(inv * p =~ point(-8, 7, 3))

    test "translation does not affect vectors":
        let
            t = translation(5, -3, 2)
            v = vector(-3, 4, 5)
        check(t * v =~ v)

    test "a scaling matrix applied to a point":
        let
            t = scaling(2, 3, 4)
            p = point(-4, 6, 8)
        check(t * p =~ point(-8, 18, 32))

    test "a scaling matrix applied to a vector":
        let
            t = scaling(2, 3, 4)
            v = vector(-4, 6, 8)
        check(t * v =~ vector(-8, 18, 32))

    test "multiplying by the inverse of a scaling matrix":
        let
            t = scaling(2, 3, 4)
            inv = inverse(t)
            v = vector(-4, 6, 8)
        check(inv * v =~ vector(-2, 2, 2))

    test "reflection is scaling by a negative value":
        let
            t = scaling(-1, 1, 1)
            p = point(2, 3, 4)
        check(t * p =~ point(-2, 3, 4))

    test "rotating a point around the x-axis":
        let
            p = point(0, 1, 0)
            halfQuarter = rotationX(PI / 4)
            fullQuarter = rotationX(PI / 2)
        check(halfQuarter * p =~ point(0, sqrt(2.0) / 2.0, sqrt(2.0) / 2.0))
        check(fullQuarter * p =~ point(0, 0, 1))