import math, fenv
import geometry

import math, sequtils
import common, geometry

type
  Matrix[N: static int, T: Number] = object
    m*: array[0..pred(N), array[0..pred(N), T]]
  Matrix2x2[T] = Matrix[2, T]
  Matrix3x3[T] = Matrix[3, T]
  Matrix4x4[T] = Matrix[4, T]
  Matrix2x2f* = Matrix2x2[Float]
  Matrix3x3f* = Matrix3x3[Float]
  Matrix4x4f* = Matrix4x4[Float]

template `[]`*[T](a: Matrix2x2[T]|Matrix3x3[T]|Matrix4x4[T], row, col: int): T =
  a.m[row][col]

template `[]=`*[T](a: Matrix2x2[T]|Matrix3x3[T]|Matrix4x4[T], row, col: int, value: T) =
  a.m[row][col] = value
  
proc matrix*(m00, m01, 
             m10, m11: Float): Matrix2x2f =
  result.m = [[m00, m01], 
              [m10, m11]]

proc matrix*(m00, m01, m02,
             m10, m11, m12,
             m20, m21, m22: Float): Matrix3x3f =
  result.m = [[m00, m01, m02], 
              [m10, m11, m12], 
              [m20, m21, m22]]

proc matrix*(m00, m01, m02, m03,
             m10, m11, m12, m13,
             m20, m21, m22, m23,
             m30, m31, m32, m33: Float): Matrix4x4f =
  result.m = [[m00, m01, m02, m03], 
              [m10, m11, m12, m13], 
              [m20, m21, m22, m23], 
              [m30, m31, m32, m33]]

const identityMatrix* = 
  matrix(1, 0, 0, 0,
         0, 1, 0, 0,
         0, 0, 1, 0,
         0, 0, 0, 1)

proc `*`*[T](a, b: Matrix4x4[T]): Matrix4x4[T] {.inline.} =
  for row in 0..3:
    for col in 0..3:
      result[row, col] = 
        a[row, 0] * b[0, col] + 
        a[row, 1] * b[1, col] + 
        a[row, 2] * b[2, col] + 
        a[row, 3] * b[3, col]

proc `*`*[T](a: Matrix4x4[T], p: Point3[T]): Point3[T] {.inline.} =
  result.x = a[0, 0] * p.x + a[0, 1] * p.y + a[0, 2] * p.z + a[0, 3] * 1
  result.y = a[1, 0] * p.x + a[1, 1] * p.y + a[1, 2] * p.z + a[1, 3] * 1
  result.z = a[2, 0] * p.x + a[2, 1] * p.y + a[2, 2] * p.z + a[2, 3] * 1

proc `*`*[T](a: Matrix4x4[T], v: Vector3[T]): Vector3[T] {.inline.} =
  result.x = a[0, 0] * v.x + a[0, 1] * v.y + a[0, 2] * v.z
  result.y = a[1, 0] * v.x + a[1, 1] * v.y + a[1, 2] * v.z
  result.z = a[2, 0] * v.x + a[2, 1] * v.y + a[2, 2] * v.z

proc transpose*[T](a: Matrix4x4[T]): Matrix4x4[T] {.inline.} =
  for row in 0..3:
    for col in 0..3:
      result[row, col] = a[col, row]

proc submatrix[N, M](a: Matrix[N, Float], row: int, col: int): Matrix[M, Float] {.inline.} =
  let 
    idxs = toSeq 0..pred(N)
    rows = filter(idxs) do (i: int) -> bool : i != row
    cols = filter(idxs) do (i: int) -> bool : i != col
  for r in 0..high(rows):
    for c in 0..high(cols):
      result[r, c] = a[rows[r], cols[c]]

proc submatrix(a: Matrix4x4f, row: int, col: int): Matrix3x3f {.inline.} =
  submatrix[4, 3](a, row, col)
      
proc submatrix(a: Matrix3x3f, row: int, col: int): Matrix2x2f {.inline.} =
  submatrix[3, 2](a, row, col)

proc determinant(a: Matrix2x2f): float {.inline.} =
  a[0, 0] * a[1, 1] - a[0, 1] * a[1, 0]
  
proc minor(a: Matrix3x3f, row: int, col: int): float {.inline.} =
  submatrix[3, 2](a, row, col).determinant()

proc cofactor(a: Matrix3x3f, row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant(a: Matrix3x3f): float {.inline.} =
  let 
    x = a[0, 0] * cofactor(a, 0, 0)
    y = a[0, 1] * cofactor(a, 0, 1)
    z = a[0, 2] * cofactor(a, 0, 2)
  x + y + z

proc minor(a: Matrix4x4f, row: int, col: int): float {.inline.} =
  submatrix[4, 3](a, row, col).determinant()

proc cofactor(a: Matrix4x4f, row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix4x4f): float {.inline.} =
  let 
    x = a[0, 0] * cofactor(a, 0, 0)
    y = a[0, 1] * cofactor(a, 0, 1)
    z = a[0, 2] * cofactor(a, 0, 2)
    w = a[0, 3] * cofactor(a, 0, 3)
  x + y + z + w

proc approx(v1, v2: Float): bool = 
  const eps = 0.000001
  abs(v1 - v2) < eps

proc inverse*(a: Matrix4x4f): Matrix4x4f =
  let d = determinant(a)
  if approx(d, 0): raise newException(Exception, "matrix is not invertible")
  for row in 0..3:
    for col in 0..3:
      let c = cofactor(a, row, col)
      # note that values are assigned transposed
      result[col, row] = c / d
