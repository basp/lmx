import math
import common

type
  Color* = object
    r*, g*, b*: Float

proc initColor*(r, g, b: Float): Color =
  result.r = r
  result.g = g
  result.b = b

proc `+`*(a, b: Color): Color {.inline.} =
  result.r = a.r + b.r
  result.g = a.g + b.g
  result.b = a.b + b.b

proc `+=`*(a: var Color, b: Color) {.inline.} =
  a.r += b.r
  a.g += b.g
  a.b += b.b

proc `-`*(a, b: Color): Color {.inline.} =
  result.r = a.r - b.r
  result.g = a.g - b.g
  result.b = a.b - b.b

proc `*`*(a: Color, c: Float): Color {.inline.} =
  result.r = a.r * c
  result.g = a.g * c
  result.b = a.b * c

proc `|*|`*(a, b: Color): Color {.inline.} =
  result.r = a.r * b.r
  result.g = a.g * b.g
  result.b = a.b * b.b
