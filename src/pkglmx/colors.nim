import math

type
  Color* = object
    r*, g*, b*: float

proc initColor*(r, g, b: float): Color {.inline.} =
  result.r = r
  result.g = g
  result.b = b

proc `+`*(c1, c2: Color): Color {.inline.} =
  result.r = c1.r + c2.r
  result.g = c1.g + c2.g
  result.b = c1.b + c2.b

proc `+=`*(c1: var Color, c2: Color) {.inline.} =
  c1.r += c2.r
  c1.g += c2.g
  c1.b += c2.b

proc `-`*(c1, c2: Color): Color {.inline.} =
  result.r = c1.r - c2.r
  result.g = c1.g - c2.g
  result.b = c1.b - c2.b

proc `*`*(c: Color, s: float): Color {.inline.} =
  result.r = c.r * s
  result.g = c.g * s
  result.b = c.b * s

proc `|*|`*(c1, c2: Color): Color {.inline.} =
  result.r = c1.r * c2.r
  result.g = c1.g * c2.g
  result.b = c1.b * c2.b

template color*(r, g, b: float): Color =
  initColor(r, g, b)
