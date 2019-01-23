import unittest, "lmx"

suite "tuples":
    test "a tuple with w = 1.0 is a point":
        let a: Vec4 = (4.3, -4.2, 3.1, 1.0)
        check(a.x == 4.3)
        check(a.y == -4.2)
        check(a.z == 3.1)
        check(a.w == 1.0)
    
    test "a tuple with w = 0.0 is a vector":
        discard