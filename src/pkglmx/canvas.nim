import colors

type
  Canvas = ref object
    width*: int
    height*: int
    pixels: seq[Color]

proc newCanvas*(width: int, height: int): Canvas {.inline.} =
  result = new Canvas
  result.pixels = newSeq[Color](height * width)
  result.width = width
  result.height = height

proc `[]`*(c: Canvas, x, y: int): Color {.inline.} =
  c.pixels[y * c.width + x]

proc `[]=`*(c: Canvas, x, y: int, v: Color) {.inline.} =
  c.pixels[y * c.width + x] = v    

proc savePPM*(c: Canvas, filename: string) =
  proc clamp(value: int, min: int, max: int): int {.inline.} =
    if value < min: return min
    if value > max: return max
    value

  proc getRGB(c: Color): tuple[r: int, g: int, b: int] =
    # make sure we don't overflow colors (i.e. keep r, g, b <= 255)
    let
      r = int(255.99 * c.r).clamp(0, 255)
      g = int(255.99 * c.g).clamp(0, 255)
      b = int(255.99 * c.b).clamp(0, 255)
    (r, g, b)

  let f = open("out.ppm", fmWrite)
  writeLine(f, "P3")
  writeLine(f, c.width, " ", c.height)
  writeLine(f, 255)
  for y in 0..pred(c.height):
    for x in 0..pred(c.width):
      let rgb = c[x, y].getRGB()
      writeLine(f, rgb.r, " ", rgb.g, " ", rgb.b)