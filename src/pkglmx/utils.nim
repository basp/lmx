import core, linalg, shapes

# these should probably be moved to tests

proc default_world*(): World {.inline.} =
  var  
      s1: Shape = sphere()
      s2: Shape = sphere()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  s1.material.color = color(0.8, 1.0, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2
  s2.transform = scaling(0.5, 0.5, 0.5)
  (@[s1, s2], @[light])

proc glass_sphere*(): Sphere {.inline.} =
  result = sphere()
  result.material.transparency = 1.0
  result.material.refractive_index = 1.5
