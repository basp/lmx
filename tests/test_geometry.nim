import unittest, math

import lmx

suite "geometry":
  test "initialize a vector with floats":
    let v = initVector3(0.1, 0.2, 0.3)
    check(v.x == 0.1)
    check(v.y == 0.2)
    check(v.z == 0.3)

  test "initialize a vector with ints":
    let v = initVector3(1, 2, 3)
    check(v.x == 1.0)
    check(v.y == 2.0)
    check(v.z == 3.0)
