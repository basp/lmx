import unittest, math
import pkglmx/common,
       pkglmx/geometry,
       utils

suite "geometry":
  test "adding two vectors":
    let 
      a1 = initVector3(3.0, -2.0, 5.0)
      a2 = initVector3(-2.0, 3.0, 1.0)
    check(a1 + a2 =~ initVector3(1.0, 1.0, 6.0))

  test "subtracting two points":
    let 
      p1 = initPoint3(3, 2, 1)
      p2 = initPoint3(5, 6, 7)
    check(p1 - p2 =~ initVector3(-2, -4, -6))

  test "subtracting a vector from a point":
    let 
      p = initPoint3(3, 2, 1)
      v = initVector3(5, 6, 7)
    check(p - v =~ initPoint3(-2, -4, -6))

  test "subtracting two vectors":
    let 
      v1 = initVector3(3, 2, 1)
      v2 = initVector3(5, 6, 7)
    check(v1 - v2 =~ initVector3(-2, -4, -6))

  test "subtracting a vector from the zero vector":
    let 
      zero = initVector3(0, 0, 0)
      v = initVector3(1, -2, 3)
    check((zero - v) =~ initVector3(-1, 2, -3))

  test "negating a vector":
    let v = -initVector3(1, -2, 3)
    check(v =~ initVector3(-1, 2, -3))  

  test "multiplying a vectpr by a scalar":
    let v = initVector3(1.0, -2, 3)
    check(v * 3.5 =~ initVector3(3.5, -7.0, 10.5))

  test "multiplying a vector by a fraction":
    let v = initVector3(1.0, -2.0, 3.0)
    check(v * 0.5 =~ initVector3(0.5, -1.0, 1.5))

  test "dividing a vector by a scalar":
    let v = initVector3(1.0, -2.0, 3.0)
    check(v / 2.0 =~ initVector3(0.5, -1.0, 1.5))

  test "computing the magnitude of vector(1, 0, 0)":
    let v = initVector3(1, 0, 0)
    check(magnitude(v) =~ 1)

  test "computing the magnitude of vector(0, 1, 0)":
    let v = initVector3(0, 1, 0)
    check(magnitude(v) =~ 1)

  test "computing the magnitude of vector(0, 0, 1)":
    let v = initVector3(0, 0, 1)
    check(magnitude(v) =~ 1)

  test "computing the magnitude of vector(1, 2, 3)":
    let v = initVector3(1, 2, 3)
    check(magnitude(v) =~ sqrt(14.0))

  test "computing the magnitude of vector(-1, -2, -3)":
    let v = initVector3(-1, -2, -3)
    check(magnitude(v) =~ sqrt(14.0))

  test "normalizing vector(4, 0, 0) gives (1, 0, 0)":
    let v = initVector3(4, 0, 0)
    check(normalize(v) =~ initVector3(1, 0, 0))

  test "normalizing vector(1, 2, 3)":
    let v = initVector3(1, 2, 3)
    check(normalize(v) =~ initVector3(0.26726, 0.53452, 0.80178))        

  test "the magnitude of a normalized vector":
    let 
      v = initVector3(1, 2, 3)
      n = normalize(v)
    check(magnitude(n) =~ 1.0)

  test "the dot product of two vectors":
    let a = initVector3(1, 2, 3)
    let b = initVector3(2, 3, 4)
    check(dot(a, b) =~ 20)

  test "the cross product of two vectors":
    let a = initVector3(1, 2, 3)
    let b = initVector3(2, 3, 4)
    check(cross(a, b) =~ initVector3(-1, 2, -1))
    check(cross(b, a) =~ initVector3(1, -2, 1))

  test "reflecting a vector approaching at 45 deg":
    let 
      v = initVector3(1.0, -1, 0)
      n = initVector3(0.0, 1, 0)
      r = reflect(v, n)
    check(r =~ initVector3(1, 1, 0))

  test "reflecting a vector off a slanted surface":
    let
      v = initVector3(0.0, -1, 0)
      n = initVector3(sqrt(2.0) / 2, sqrt(2.0) / 2, 0)
      r = reflect(v, n)
    check(r =~ initVector3(1, 0, 0))    
