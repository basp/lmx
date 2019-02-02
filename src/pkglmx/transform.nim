import math, fenv
import geometry

type
  Matrix2x2 = object
    m00, m01: Float
    m10, m11: Float

  Matrix3x3 = object
    m00, m01, m02: Float
    m10, m11, m12: Float
    m20, m21, m22: Float

  Matrix4x4 = object
    m00, m01, m02, m03: Float
    m10, m11, m12, m13: Float
    m20, m21, m22, m23: Float
    m30, m31, m32, m33: Float

