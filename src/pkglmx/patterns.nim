import math, linalg, core

type
    Stripes = ref object of Pattern
    Rings = ref object of Pattern
    Checkers = ref object of Pattern
    Gradient = ref object of Pattern

proc stripe_at*(pat: Stripes, p: Vec4): Color {.inline.} =
    if floor(p.x) mod 2 == 0: 
        return pat.a
    else:
        return pat.b
    
proc stripe_pattern*(a: Color, b: Color): Stripes {.inline.} =
    Stripes(a: a, b: b, transform: identity)
    
proc gradient_pattern*(a: Color, b: Color): Gradient {.inline.} =
    Gradient(a: a, b: b, transform: identity)
    
proc ring_pattern*(a: Color, b: Color): Rings {.inline.} =
    Rings(a: a, b: b, transform: identity)
    
proc checkers_pattern*(a: Color, b: Color): Checkers {.inline.} =
    Checkers(a: a, b: b)

method pattern_at*(pat: Stripes, p: Vec4): Color {.inline.} =
  stripe_at(pat, p)

method pattern_at*(pat: Rings, p: Vec4): Color {.inline.} =
  if floor(sqrt(p.x * p.x + p.z * p.z)) mod 2 == 0:
    return pat.a
  else:
    return pat.b

method pattern_at*(pat: Checkers, p: Vec4): Color {.inline.} =
    if (floor(p.x) + floor(p.y) + floor(p.z)) mod 2 == 0:
      return pat.a
    else:
      return pat.b

method pattern_at*(pat: Gradient, p: Vec4): Color =
  let
    distance = pat.b - pat.a
    fraction = p.x - floor(p.x)
  pat.a + distance * fraction