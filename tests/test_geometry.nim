import unittest, math
import pkglmx/geometry

proc `=~`(v1, v2: Float): bool =
  const eps = 0.00001
  abs(v1 - v2) < eps

proc `=~`[T](v1, v2: Vector3[T]): bool =
  v1.x =~ v2.x and v1.y =~ v2.y and v1.z =~ v2.z

proc `=~`[T](p1, p2: Point3[T]): bool =
  p1.x =~ p2.x and p1.y =~ p2.y and p1.z =~ p2.z

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

  # test "colors are (red, green, blue) tuples":
  #     let c = color(-0.5, 0.4, 1.7)
  #     check(c.r == -0.5)
  #     check(c.g == 0.4)
  #     check(c.b == 1.7)

  # test "adding colors":
  #     let c1 = color(0.9, 0.6, 0.75)
  #     let c2 = color(0.7, 0.1, 0.25)
  #     check((c1 + c2) =~ color(1.6, 0.7, 1.0))

  # test "subtracting colors":
  #     let c1 = color(0.9, 0.6, 0.75)
  #     let c2 = color(0.7, 0.1, 0.25)
  #     check((c1 - c2) =~ color(0.2, 0.5, 0.5))

  # test "multiplying a color by a scalar":
  #     let c = color(0.2, 0.3, 0.4)
  #     check((c * 2) =~ color(0.4, 0.6, 0.8))

  # test "multiplying colors":
  #     let c1 = color(1.0, 0.2, 0.4)
  #     let c2 = color(0.9, 1.0, 0.1)
  #     check((c1 * c2) =~ color(0.9, 0.2, 0.04))

  # test "reflecting a vector approaching at 45 deg":
  #     let 
  #         v = vector(1, -1, 0)
  #         n = vector(0, 1, 0)
  #         r = reflect(v, n)
  #     check(r =~ vector(1, 1, 0))

  # test "reflecting a vector off a slanted surface":
  #     let
  #         v = vector(0, -1, 0)
  #         n = vector(sqrt(2.0) / 2, sqrt(2.0) / 2, 0)
  #         r = reflect(v, n)
  #     check(r =~ vector(1, 0, 0))