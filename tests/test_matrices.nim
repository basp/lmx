import unittest, math
import lmx, utils

suite "matrices":
  test "constructing a 4x4 matrix":
    let m = matrix(1.00, 2.00, 3.00, 4.00,
                   5.50, 6.50, 7.50, 8.50,
                   9.00, 10.0, 11.0, 12.0,
                   13.5, 14.5, 15.5, 16.5)
    check(m[0, 0] == 1.0)
    check(m[0, 3] == 4.0)
    check(m[1, 0] == 5.5)
    check(m[1, 2] == 7.5)
    check(m[2, 2] == 11.0)
    check(m[3, 0] == 13.5)
    check(m[3, 2] == 15.5)

  test "constructing a 2x2 matrix":
    let m = matrix(-3.0, 5.00,
                   1.00, -2.0)
    check(m[0, 0] == -3.0)
    check(m[0, 1] == 5.0)
    check(m[1, 0] == 1.0)
    check(m[1, 1] == -2.0)

  test "constructing a 3x3 matrix":
    let m = matrix(-3.0, 5.00, 0.00,
                   1.00, -2.0, -7.0,
                   0.00, 1.00, 1.00)
    check(m[0, 0] == -3.0)
    check(m[1, 1] == -2.0)
    check(m[2, 2] == 1.0)

  test "matrix equality with identical matrices":
    let 
      a = matrix(1.0, 2.0, 3.0, 4.0,
                 5.0, 6.0, 7.0, 8.0,
                 9.0, 8.0, 7.0, 6.0,
                 5.0, 4.0, 3.0, 2.0)
      b = matrix(1.0, 2.0, 3.0, 4.0,
                 5.0, 6.0, 7.0, 8.0,
                 9.0, 8.0, 7.0, 6.0,
                 5.0, 4.0, 3.0, 2.0)
    check(a =~ b)

  test "matrix equality with different matrices":
    let 
      a = matrix(1.0, 2.0, 3.0, 4.0,
                 5.0, 6.0, 7.0, 8.0,
                 9.0, 8.0, 7.0, 6.0,
                 5.0, 4.0, 3.0, 2.0)
      b = matrix(2.0, 3.0, 4.0, 5.0,
                 6.0, 7.0, 8.0, 9.0,
                 8.0, 7.0, 6.0, 5.0,
                 4.0, 3.0, 2.0, 1.0)
    check(not (a =~ b))

  test "multiplying two matrices":
    let
      a = matrix(1.0, 2.0, 3.0, 4.0,
                 5.0, 6.0, 7.0, 8.0,
                 9.0, 8.0, 7.0, 6.0,
                 5.0, 4.0, 3.0, 2.0)
      b = matrix(-2.0, 1.0, 2.0, 3.00,
                 3.00, 2.0, 1.0, -1.0,
                 4.00, 3.0, 6.0, 5.00,
                 1.00, 2.0, 7.0, 8.00)
      e = matrix(20.00, 22.00, 50.00, 48.00,
                 44.00, 54.00, 114.0, 108.0,
                 40.00, 58.00, 110.0, 102.0,
                 16.00, 26.00, 46.00, 42.00)
    check((a * b) =~ e)

  test "a matrix multiplied by a point":
    let 
      a = matrix(1.0, 2.0, 3.0, 4.0,
                 2.0, 4.0, 4.0, 2.0,
                 8.0, 6.0, 4.0, 1.0,
                 0.0, 0.0, 0.0, 1.0)
      b = point(1.0, 2.0, 3.0)
      e = point(18.0, 24.0, 33.0)
    check((a * b) =~ e)

  test "multiplying a matrix by the identity matrix":
    let a = matrix(0.0, 1.0, 2.00, 4.00,
                   1.0, 2.0, 4.00, 8.00,
                   2.0, 4.0, 8.00, 16.0,
                   4.0, 8.0, 16.0, 32.0)
    check((a * identityMatrix) =~ a)

  test "transposing a matrix":
    let 
      a = matrix(0.0, 9.0, 3.0, 0.0,
                 9.0, 8.0, 0.0, 8.0,
                 1.0, 8.0, 5.0, 3.0,
                 0.0, 0.0, 5.0, 8.0)
      e = matrix(0.0, 9.0, 1.0, 0.0,
                 9.0, 8.0, 8.0, 0.0,
                 3.0, 0.0, 5.0, 5.0,
                 0.0, 8.0, 3.0, 8.0)
    check(a.transpose() =~ e)

  test "transposing the identity matrix":
    let a = identityMatrix.transpose()
    check(a =~ identityMatrix)

  test "calculating the determinant of a 2x2 matrix":
    let a = matrix(1.00, 5.0, -3.0, 2.0)
    check(a.determinant() =~ 17.0)

  test "a submatrix of a 3x3 matrix is a 2x2 matrix":
    let 
      a = matrix(1.00, 5.0, 0.00,
                 -3.0, 2.0, 7.00,
                 0.00, 6.0, -3.0)
      e = matrix(-3.0, 2.0, 0.0, 6.0)
    check(a.submatrix(0, 2) =~ e)

  test "a submatrix of a 4x4 matrix is a 3x3 matrix":
    let 
      a = matrix(-6.0, 1.0, 1.00, 6.0,
                 -8.0, 5.0, 8.00, 6.0,
                 -1.0, 0.0, 8.00, 2.0,
                 -7.0, 1.0, -1.0, 1.0)
      e = matrix(-6.0, 1.00, 6.0,
                 -8.0, 8.00, 6.0,
                 -7.0, -1.0, 1.0)
    check(a.submatrix(2, 1) =~ e)

  test "calculating the minor of a 3x3 matrix":
    let 
      a = matrix(-3.0, 5.00, 0.00,
                 2.00, -1.0, -7.0,
                 6.00, -1.0, 5.00)
      b = a.submatrix(1, 0)
    check(b.determinant() =~ 25.0)
    check(a.minor(1, 0) =~ 25.0)

  test "calculating the cofactor of a 3x3 matrix":
    let a = matrix(3.0, 5.00, 0.00,
                   2.0, -1.0, -7.0,
                   6.0, -1.0, 5.00)
    check(a.minor(0, 0) =~ -12.0)
    check(a.cofactor(0, 0) =~ -12.0)
    check(a.minor(1, 0) =~ 25)
    checK(a.cofactor(1, 0) =~ -25.0)

  test "calculating the determinant of a 3x3 matrix":
    let a = matrix(1.00, 2.0, 6.00,
                   -5.0, 8.0, -4.0,
                   2.00, 6.0, 4.00)
    check(cofactor(a, 0, 0) =~ 56.0)
    check(cofactor(a, 0, 1) =~ 12)
    check(cofactor(a, 0, 2) =~ -46.0)
    check(determinant(a) =~ -196.0)

  test "calculating the determinant of a 4x4 matrix":
    let a = matrix(-2.0, -8.0, 3.00, 5.00,
                   -3.0, 1.00, 7.00, 3.00,
                   1.00, 2.00, -9.0, 6.00,
                   -6.0, 7.00, 7.00, -9.0)
    check(cofactor(a, 0, 0) =~ 690)
    check(cofactor(a, 0, 1) =~ 447)
    check(cofactor(a, 0, 2) =~ 210)
    check(cofactor(a, 0, 3) =~ 51)
    checK(determinant(a) =~ -4071)

  test "testing an invertible matrix for invertibility":
    let a = matrix(6.0, 4.00, 4.0, 4.00,
                   5.0, 5.00, 7.0, 6.00,
                   4.0, -9.0, 3.0, -7.0,
                   9.0, 1.00, 7.0, -6.0)
    check(determinant(a) =~ -2120)
    check(a.invertible())

  test "testing a non-invertible matrix for invertibility":
    let a = matrix(-4.0, 2.00, -2.0, -3.0,
                   9.00, 6.00, 2.00, 6.00,
                   0.00, -5.0, 1.00, -5.0,
                   0.00, 0.00, 0.00, 0.00)
    check(determinant(a) =~ 0)
    check(not a.invertible())

  test "calculating the inverse of a matrix":
    let 
      a = matrix(-5.0, 2.00, 6.00, -8.0,
                 1.00, -5.0, 1.00, 8.00,
                 7.00, 7.00, -6.0, -7.0,
                 1.00, -3.0, 7.00, 4.00)
      b = a.inverse()
      e = matrix(0.218050, 0.451130, 0.240600, -0.04511,
                 -0.80827, -1.45677, -0.44361, 0.520680,
                 -0.07895, -0.22368, -0.05263, 0.197370,
                 -0.52256, -0.81391, -0.30075, 0.306390)
    check(determinant(a) =~ 532)
    check(cofactor(a, 2, 3) =~ -160)
    check(b[3, 2] =~ -160.0 / 532.0)
    check(cofactor(a, 3, 2) =~ 105)
    check(b[2, 3] =~ 105.0 / 532.0)
    check(b =~ e)

  test "calculating the inverse of another matrix":
    let 
      a = matrix(8.00, -5.0, 9.00, 2.00,
                 7.00, 5.00, 6.00, 1.00,
                 -6.0, 0.00, 9.00, 6.00,
                 -3.0, 0.00, -9.0, -4.0)
      e = matrix(-0.15385, -0.15385, -0.28205, -0.53846,
                 -0.07692, 0.123080, 0.025640, 0.030770,
                 0.358970, 0.358970, 0.435900, 0.923080,
                 -0.69231, -0.69231, -0.76923, -1.92308)
    check(a.inverse() =~ e)

  test "calculating the inverse of a third matrix":
    let 
      a = matrix(9.00, 3.00, 0.00, 9.00,
                 -5.0, -2.0, -6.0, -3.0,
                 -4.0, 9.00, 6.00, 4.00,
                 -7.0, 6.00, 6.00, 2.00)
      e = matrix(-0.04074, -0.07778, 0.144440, -0.22222,
                 -0.07778, 0.033330, 0.366670, -0.33333,
                 -0.02901, -0.14630, -0.10926, 0.129630,
                 0.177780, 0.066670, -0.26667, 0.333330)
    check(inverse(a) =~ e)

  test "multiplying a product by its inverse":
    let 
      a = matrix(3.0, -9.0, 7.00, 3.00,
                 3.0, -8.0, 2.00, -9.0,
                 -4.0, 4.0, 4.00, 1.00,
                 -6.0, 5.0, -1.0, 1.00)
      b = matrix(8.0, 2.00, 2.0, 2.0,
                 3.0, -1.0, 7.0, 0.0,
                 7.0, 0.00, 5.0, 4.0,
                 6.0, -2.0, 0.0, 5.0)
      c = a * b
    check(c * inverse(b) =~ a)
