import math, sequtils
import geometry

type
  Matrix[N: static int] = object
    arr*: array[0..pred(N), array[0..pred(N), float]]
  Matrix2x2* = Matrix[2]
  Matrix3x3* = Matrix[3]
  Matrix4x4* = Matrix[4]

const eps = 0.00001

template `[]`*(m: Matrix2x2|Matrix3x3|Matrix4x4, i, j: int): float =
  m.arr[i][j]

template `[]=`*(m: var Matrix2x2|var Matrix3x3|var Matrix4x4, 
                i, j: int, val: float) =
  m.arr[i][j] = val

proc initMatrix2x2*(m00, m01, 
                    m10, m11: float): Matrix2x2 {.inline.} =
  result.arr[0][0] = m00
  result.arr[0][1] = m01
  result.arr[1][0] = m10
  result.arr[1][1] = m11

proc initMatrix3x3*(m00, m01, m02, 
                    m10, m11, m12, 
                    m20, m21, m22: float): Matrix3x3 {.inline.} =
  result.arr[0][0] = m00
  result.arr[0][1] = m01
  result.arr[0][2] = m02
  result.arr[1][0] = m10
  result.arr[1][1] = m11
  result.arr[1][2] = m12
  result.arr[2][0] = m20
  result.arr[2][1] = m21
  result.arr[2][2] = m22

proc initMatrix4x4*(m00, m01, m02, m03,
                    m10, m11, m12, m13,
                    m20, m21, m22, m23,
                    m30, m31, m32, m33: float): Matrix4x4 {.inline.} =
  result.arr[0][0] = m00
  result.arr[0][1] = m01
  result.arr[0][2] = m02
  result.arr[0][3] = m03
  result.arr[1][0] = m10
  result.arr[1][1] = m11
  result.arr[1][2] = m12
  result.arr[1][3] = m13
  result.arr[2][0] = m20
  result.arr[2][1] = m21
  result.arr[2][2] = m22
  result.arr[2][3] = m23
  result.arr[3][0] = m30
  result.arr[3][1] = m31
  result.arr[3][2] = m32
  result.arr[3][3] = m33

const identityMatrix* = 
  initMatrix4x4(1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1)

proc `*`*[N](a, b: Matrix[N]): Matrix[N] {.inline.} =
  for i in 0..pred(N):
    for j in 0..pred(N):
      result[i, j] = a[i, 0] * b[0, j] +
                     a[i, 1] * b[1, j] +
                     a[i, 2] * b[2, j] +
                     a[i, 3] * b[3, j]

proc `*`*(m: Matrix4x4, p: Point3): Point3 {.inline.} =
  result.x = m[0, 0] * p.x + m[0, 1] * p.y + m[0, 2] * p.z + m[0, 3]
  result.y = m[1, 0] * p.x + m[1, 1] * p.y + m[1, 2] * p.z + m[1, 3]
  result.z = m[2, 0] * p.x + m[2, 1] * p.y + m[2, 2] * p.z + m[2, 3]
  let w = m[3, 0] * p.x + m[3, 1] * p.y + m[3, 2] * p.z + m[3, 3]
  if abs(w - 1) < eps: return
  if abs(w) < eps: return
  result.x /= w
  result.y /= w
  result.z /= w

proc `*`*(m: Matrix4x4, v: Vector3): Vector3 {.inline.} =
  result.x = m[0, 0] * v.x + m[0, 1] * v.y + m[0, 2] * v.z
  result.y = m[1, 0] * v.x + m[1, 1] * v.y + m[1, 2] * v.z
  result.z = m[2, 0] * v.x + m[2, 1] * v.y + m[2, 2] * v.z

proc transpose*[N](m: Matrix[N]): Matrix[N] {.inline.} =
  for i in 0..pred(N):
    for j in 0..pred(N):
      result[i, j] = m[j, i]

proc determinant*(m: Matrix2x2): float {.inline.} =
  m[0, 0] * m[1, 1] - m[0, 1] * m[1, 0]

proc submatrix[N, M](a: Matrix[N], row, col: int): Matrix[M] {.inline.} =
  let 
    idxs = toSeq 0..pred(N)
    rows = filter(idxs) do (i: int) -> bool : i != row
    cols = filter(idxs) do (i: int) -> bool : i != col
  for r in 0..high(rows):
    for c in 0..high(cols):
      result[r, c] = a[rows[r], cols[c]]

proc submatrix*(m: Matrix3x3, row, col: int): Matrix2x2 {.inline.} =
  submatrix[3, 2](m, row, col)

proc submatrix*(m: Matrix4x4, row, col: int): Matrix3x3 {.inline.} =
  submatrix[4, 3](m, row, col)

proc minor*(m: Matrix3x3, row, col: int): float {.inline.} =
  submatrix[3, 2](m, row, col).determinant()

proc cofactor*(m: Matrix3x3, row, col: int): float {.inline.} =
  result = m.minor(row, col)
  if (row + col) mod 2 == 1:
    result = -result

proc determinant*(m: Matrix3x3): float {.inline.} =
  result += m[0, 0] * m.cofactor(0, 0)
  result += m[0, 1] * m.cofactor(0, 1)
  result += m[0, 2] * m.cofactor(0, 2)

proc minor*(m: Matrix4x4, row, col: int): float {.inline.} =
  submatrix[4, 3](m, row, col).determinant()

proc cofactor*(m: Matrix4x4, row, col: int): float {.inline.} =
  result = m.minor(row, col)
  if (row + col) mod 2 == 1:
    result = -result

proc determinant*(m: Matrix4x4): float {.inline.} =
  result += m[0, 0] * m.cofactor(0, 0)
  result += m[0, 1] * m.cofactor(0, 1)
  result += m[0, 2] * m.cofactor(0, 2)
  result += m[0, 3] * m.cofactor(0, 3)

proc invertible*(m: Matrix4x4): bool {.inline.} =
  let det = m.determinant()
  abs(det) >= eps

proc inverse*(m: Matrix4x4): Matrix4x4 {.inline.} =
  let det = m.determinant()
  if abs(det) < eps: raise newException(Exception, "matrix is not invertible")
  let fac = 1 / det
  for i in 0..3:
    for j in 0..3:
      let c = m.cofactor(i, j)
      result[j, i] = c * fac

template matrix*(m00, m01, 
                 m10, m11: float): Matrix2x2 =
  initMatrix2x2(m00, m01, 
                m10, m11)

template matrix*(m00, m01, m02,
                 m10, m11, m12,
                 m20, m21, m22: float): Matrix3x3 =
  initMatrix3x3(m00, m01, m02,
                m10, m11, m12,
                m20, m21, m22)

template matrix*(m00, m01, m02, m03,
                 m10, m11, m12, m13,
                 m20, m21, m22, m23,
                 m30, m31, m32, m33: float): Matrix4x4 =
  initMatrix4x4(m00, m01, m02, m03,
                m10, m11, m12, m13,
                m20, m21, m22, m23,
                m30, m31, m32, m33)

type
  Transform* = object
    m*, inv*, invt*: Matrix4x4

proc initTransform*(m: Matrix4x4): Transform {.inline.} =
  result.m = m
  result.inv = m.inverse()
  result.invt = result.inv.transpose()

template translation*(x, y, z: float): Matrix4x4 =
  matrix(1, 0, 0, x,
         0, 1, 0, y,
         0, 0, 1, z,
         0, 0, 0, 1)

template scaling*(x, y, z: float): Matrix4x4 =
  matrix(x, 0, 0, 0,
         0, y, 0, 0,
         0, 0, z, 0,
         0, 0, 0, 1)

template rotationX*(r: float): Matrix4x4 =
  matrix(1, 0, 0, 0,
         0, cos(r), -sin(r), 0,
         0, sin(r), cos(r), 0,
         0, 0, 0, 1)

template rotationY*(r: float): Matrix4x4 =
  matrix(cos(r), 0, sin(r), 0,
         0, 1, 0, 0,
         -sin(r), 0, cos(r), 0,
         0, 0, 0, 1)

template rotationZ*(r: float): Matrix4x4 =
  matrix(cos(r), -sin(r), 0, 0,
         sin(r), cos(r), 0, 0,
         0, 0, 1, 0,
         0, 0, 0, 1)

template shearing*(xy, xz, yx, yz, zx, zy: float): Matrix4x4 =
  matrix(1, xy, xz, 0,
         yx, 1, yz, 0,
         zx, zy, 1, 0,
         0, 0, 0, 1)

template view*(`from`, to: Point3, up: Vector3): Matrix4x4 =
  let 
    fwd = normalize(to - `from`)
    upn = up.normalize()
    left = cross(fwd, upn)
    trueUp = cross(left, fwd)
    orientation = matrix(left.x, left.y, left.z, 0,
                         trueUp.x, trueUp.y, trueUp.z, 0,
                         -fwd.x, -fwd.y, -fwd.z, 0,
                         0, 0, 0, 1)
  orientation * translation(-`from`.x, -`from`.y, -`from`.z)

proc translate*(m: Matrix4x4, x, y, z: float): Matrix4x4 {.inline.} =
  translation(x, y, z) * m

proc scale*(m: Matrix4x4, x, y, z: float): Matrix4x4 {.inline.} =
  scaling(x, y, z) * m

proc rotateX*(m: Matrix4x4, r: float): Matrix4x4 {.inline.} =
  rotationX(r) * m

proc rotateY*(m: Matrix4x4, r: float): Matrix4x4 {.inline.} =
  rotationY(r) * m

proc rotateZ*(m: Matrix4x4, r: float): Matrix4x4 {.inline.} =
  rotationZ(r) * m

proc shear*(m: Matrix4x4, xy, xz, yx, yz, zx, zy: float): Matrix4x4 {.inline.} =
  shearing(xy, xz, yz, yz, zx, zy) * m

proc `*`*(m: Matrix4x4, ray: Ray): Ray {.inline.} =
  result.origin = m * ray.origin
  result.direction = m * ray.direction