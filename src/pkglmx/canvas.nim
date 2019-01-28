import times, core, linalg

type
  Canvas = ref object
    hsize*: int
    vsize*: int
    pixels: seq[Color]

proc canvas*(hsize: int, vsize: int): Canvas {.inline.} =
  let pixels = newSeq[Color](hsize * vsize)
  Canvas(hsize: hsize, vsize: vsize, pixels: pixels)

proc write_pixel(canvas: Canvas, x: int, y: int, color: Color) {.inline.} =
  let i = y * canvas.hsize + x
  canvas.pixels[i] = color

proc render*(camera: Camera, world: World, show_progress = false): Canvas =
  result = canvas(camera.hsize, camera.vsize)
  for y in 0..pred(camera.vsize):
    let start = now()
    for x in 0..pred(camera.hsize):
      let
        ray = ray_for_pixel(camera, x, y)
        color = color_at(world, ray)
      write_pixel(result, x, y, color)
    let 
      finish = now()
      dur = finish - start
    if show_progress:
      echo succ(y), "/", camera.vsize, " (", dur, ")"

proc pixel_at*(canvas: Canvas, x: int, y: int): Color {.inline.} =
  canvas.pixels[y * canvas.hsize + x]