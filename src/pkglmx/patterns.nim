import math
import geometry, colors, transform, common

type
  StripePattern = ref object of Pattern
    a*, b*: Color
  GradientPattern = ref object of Pattern
    a*, b*: Color
  RingPattern = ref object of Pattern
    a*, b*: Color
  CheckersPattern = ref object of Pattern
    a*, b*: Color

proc newStripePattern*(a, b: Color): StripePattern {.inline.} =
  result = new StripePattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

proc newGradientPattern*(a, b: Color): GradientPattern {.inline.} =
  result = new GradientPattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

proc newRingPattern*(a, b: Color): RingPattern {.inline.} =
  result = new RingPattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

proc newCheckersPattern*(a, b: Color): CheckersPattern {.inline.} =
  result = new CheckersPattern
  result.transform = identityMatrix.initTransform()
  result.a = a
  result.b = b

method colorAt*(pat: StripePattern, p: Point3): Color =
  if floor(p.x) mod 2 == 0: pat.a else: pat.b

method colorAt*(pat: GradientPattern, p: Point3): Color =
  let
    distance = pat.b - pat.a
    fraction = p.x - floor(p.x)
  pat.a + distance * fraction

method colorAt*(pat: RingPattern, p: Point3): Color =
  if floor(sqrt(p.x * p.x + p.z + p.z)) mod 2 == 0: pat.a else: pat.b

method colorAt*(pat: CheckersPattern, p: Point3): Color =
  let
    fx = floor(p.x)
    fy = floor(p.y)
    fz = floor(p.z)
  if (fx + fy + fz) mod 2 == 0: pat.a else: pat.b
