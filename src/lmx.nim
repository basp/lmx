import math, sequtils

type
  Vec4* = tuple[x: float, y: float, z: float, w: float]
  Color* = tuple[r: float, g: float, b: float]
  Matrix*[N: static[int]] = array[0..N-1, array[0..N-1, float]]

const identity* : Matrix[4] = [[1.0, 0.0, 0.0, 0.0],
                               [0.0, 1.0, 0.0, 0.0],
                               [0.0, 0.0, 1.0, 0.0],
                               [0.0, 0.0, 0.0, 1.0]]

proc isPoint*(v: Vec4): bool {.inline.} =
  v.w == 1.0

proc isVector*(v: Vec4): bool {.inline.} =
  v.w == 0.0

proc point*(x: float, y: float, z: float): Vec4 {.inline.} =
  (x, y, z, 1.0)

proc vector*(x: float, y: float, z: float): Vec4 {.inline.} =
  (x, y, z, 0.0)

proc color*(r: float, g: float, b: float): Color {.inline.} =
  (r, g, b)

proc `=~`*(a: float, b: float): bool {.inline.} =
  const epsilon = 0.00001
  abs(a - b) < epsilon

proc `=~`*(a: Vec4, b: Vec4): bool {.inline.} =
  a.x =~ b.x and a.y =~ b.y and a.z =~ b.z and a.w =~ b.w

proc `=~`*(a: Color, b: Color): bool {.inline.} =
  a.r =~ b.r and a.g =~ b.g and a.b =~ b.b

proc `+`*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  (a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)

proc `+`*(a: Color, b: Color): Color {.inline.} =
  (a.r + b.r, a.g + b.g, a.b + b.b)

proc `-`*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  (a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)

proc `-`*(a: Color, b: Color): Color {.inline.} =
  (a.r - b.r, a.g - b.g, a.b - b.b)

proc `-`*(a: Vec4): Vec4 {.inline.} =
  (-a.x, -a.y, -a.z, -a.w)

proc `*`*(c: float, a: Vec4): Vec4 {.inline.} =
  (c * a.x, c * a.y, c * a.z, c * a.w)

proc `*`*(c: float, a: Color): Color {.inline.} =
  (c * a.r, c * a.g, c * a.b)

proc `*`*(a: Vec4, c: float): Vec4 {.inline.} =
  (c * a.x, c * a.y, c * a.z, c * a.w)

proc `*`*(a: Color, c: float): Color {.inline.} =
  (c * a.r, c * a.g, c * a.b)

proc `*`*(a: Color, b: Color): Color {.inline.} =
  (a.r * b.r, a.g * b.g, a.b * b.b)

proc `/`*(a: Vec4, c: float): Vec4 {.inline.} =
  (a.x / c, a.y / c, a.z / c, a.w / c)

proc magnitude*(a: Vec4): float {.inline.} =
  sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)

proc normalize*(a: Vec4): Vec4 {.inline.} =
  let mag = magnitude(a)
  (a.x / mag, a.y / mag, a.z / mag, a.w / mag)

proc dot*(a: Vec4, b: Vec4): float {.inline.} =
  a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc cross*(a: Vec4, b: Vec4): Vec4 {.inline.} =
  vector(a.y * b.z - a.z * b.y,
         a.z * b.x - a.x * b.z,
         a.x * b.y - a.y * b.x)

proc `[]`*[N](m: Matrix[N], row: int, col: int): float {.inline.} =
  m[row][col]

proc row*[N](m: Matrix[N], row: int): Vec4 {.inline.} =
  (m[row][0], m[row][1], m[row][2], m[row][3])

proc col*[N](m: Matrix[N], col: int): Vec4 {.inline.} =
  (m[0][col], m[1][col], m[2][col], m[3][col])

proc `=~`*[N](a, b: Matrix[N]): bool {.inline.} =
  for r in 0..N-1:
    for c in 0..N-1:
      if not (a[r][c] =~ b[r][c]):
        return false
  true     

proc `*`*[N](a, b: Matrix[N]): Matrix[N] {.inline.} =
  var z : Matrix[N]
  for r in 0..N-1:
    for c in 0..N-1:
      z[r][c] = dot(row(a, r), col(b, c))
  z

proc `*`*(a: Matrix[4], b: Vec4): Vec4 {.inline.} =
  (dot(row(a, 0), b), dot(row(a, 1), b), dot(row(a, 2), b), dot(row(a, 3), b))

proc transpose*[N](a: Matrix[N]): Matrix[N] {.inline.} =
  var b: Matrix[N]
  for r in 0..N-1:
    for c in 0..N-1:
      b[c][r] = a[r][c]
  b

proc determinant*(a: Matrix[2]): float {.inline.} =
  a[0][0] * a[1][1] - a[0][1] * a[1][0]

proc submatrix[N, M](a: Matrix[N], row: int, col: int): Matrix[M] =
  let 
    idxs = toSeq 0..N-1
    rows = filter(idxs) do (i: int) -> bool : i != row
    cols = filter(idxs) do (i: int) -> bool : i != col
  var b: Matrix[M]
  for r in 0..high(rows):
    for c in 0..high(cols):
      b[r][c] = a[rows[r]][cols[c]]
  b  

proc submatrix*(a: Matrix[3], row: int, col: int): Matrix[2] {.inline.} =
  submatrix[3, 2](a, row, col)

proc submatrix*(a: Matrix[4], row: int, col: int): Matrix[3] {.inline.} =
  submatrix[4, 3](a, row, col)

proc minor*(a: Matrix[3], row: int, col: int): float {.inline.} =
  submatrix[3, 2](a, row, col).determinant()

proc cofactor*(a: Matrix[3], row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix[3]): float =
  let 
    x = a[0][0] * cofactor(a, 0, 0)
    y = a[0][1] * cofactor(a, 0, 1)
    z = a[0][2] * cofactor(a, 0, 2)
  x + y + z

proc minor*(a: Matrix[4], row: int, col: int): float {.inline.} =
  submatrix[4, 3](a, row, col).determinant()

proc cofactor*(a: Matrix[4], row: int, col: int): float {.inline.} =
  let m = minor(a, row, col)
  if (row + col) mod 2 == 0: m else: -m

proc determinant*(a: Matrix[4]): float =
  let 
    x = a[0][0] * cofactor(a, 0, 0)
    y = a[0][1] * cofactor(a, 0, 1)
    z = a[0][2] * cofactor(a, 0, 2)
    w = a[0][3] * cofactor(a, 0, 3)
  x + y + z + w

proc isInvertible*(a: Matrix[4]): bool {.inline.} =
  not (determinant(a) =~ 0)

proc inverse*(a: Matrix[4]): Matrix[4] =
  let d = determinant(a)
  var b: Matrix[4]
  for row in 0..3:
    for col in 0..3:
      let c = cofactor(a, row, col)
      b[col][row] = c / d #transposed
  b

when isMainModule:
  echo("Hello, World!")
