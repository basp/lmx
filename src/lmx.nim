import math, sequtils, options

import pkglmx/geometry,
       pkglmx/transform,
       pkglmx/colors,
       pkglmx/common,
       pkglmx/world,
       pkglmx/canvas,
       pkglmx/camera,
       pkglmx/patterns,
       pkglmx/shapes

export geometry,
       transform,
       colors,
       common,
       world,
       canvas,
       camera,
       patterns,
       shapes

when isMainModule:
  const size = 15

  let checkers = newCheckersPattern(color(1, 1, 1), color(0, 0, 0))

  let floor: Shape = newPlane()
  floor.material.specular = 0
  floor.material.pattern = some(Pattern(checkers))

  let w1: Shape = newPlane()
  w1.material.specular = 0
  w1.material.pattern = some(Pattern(checkers))
  w1.transform = identityMatrix.
      rotateX(-PI / 2).
      translate(0, 0, size).initTransform()

  let w2: Shape = newPlane()
  w2.material.specular = 0
  w2.material.pattern = some(Pattern(checkers))
  w2.transform = identityMatrix.
    rotateZ(-PI / 2).
    translate(-size, 0, 0).initTransform()

  let w3: Shape = newPlane()
  w3.material.specular = 0
  w3.material.pattern = some(Pattern(checkers))
  w3.transform = identityMatrix.
    rotateZ(PI / 2).
    translate(size, 0, 0).initTransform()

  let w4: Shape = newPlane()
  w4.material.specular = 0
  w4.material.pattern = some(Pattern(checkers))
  w4.transform = identityMatrix.
    rotateX(PI / 2).
    translate(0, 0, -size).initTransform()

  let w5: Shape = newPlane()
  w5.material.specular = 0
  w5.material.pattern = some(Pattern(checkers))
  w5.transform = identityMatrix.
    rotateX(PI).
    translate(0, -size, 0).initTransform()

  let s1: Shape = newSphere()
  s1.material.transparency = 0.96
  s1.material.refractiveIndex = 1.52
  s1.material.reflective = 0.5
  s1.material.ambient = 0
  s1.material.diffuse = 0.01
  s1.transform = identityMatrix.
    scale(3, 3, 3).
    translate(0, 3, 0).initTransform()

  let s2: Shape = newSphere()
  s2.material.transparency = 1.0
  s2.material.refractiveIndex = 1.0
  s2.material.ambient = 0
  s2.material.diffuse = 0
  s2.transform = identityMatrix.
    scale(2.5, 2.5, 2.5).
    translate(0, 3, 0).initTransform()

  let light = newPointLight(point(-1, 10, 1), color(1, 1, 1))

  let w = newWorld()
  w.objects.add(floor)
  w.objects.add(w1)
  w.objects.add(w2)
  w.objects.add(w3)
  w.objects.add(w4)
  w.objects.add(w5)
  w.objects.add(s1)
  w.objects.add(s2)
  w.lights.add(light)

  let cam = newCamera(400, 200, PI / 2)
  cam.transform = view(
    point(0, 12, 0),
    point(0, 0, 0),
    vector(0, 0, 1)).initTransform()

  let img = cam.render(w)
  img.savePPM("out.ppm")

  # let floor: Shape = newSphere()
  # floor.transform = scaling(10, 0.01, 10).initTransform()
  # floor.material = initMaterial()
  # floor.material.color = color(1, 0.9, 0.9)
  # floor.material.specular = 0

  # let leftWall: Shape = newSphere()
  # leftWall.transform = identityMatrix.
  #   scale(10, 0.01, 10).
  #   rotateX(PI / 2).
  #   rotateY(-PI / 4).
  #   translate(0, 0, 5).initTransform()
  # leftWall.material = floor.material

  # let rightWall: Shape = newSphere()
  # rightWall.transform = identityMatrix.
  #   scale(10, 0.01, 10).
  #   rotateX(PI / 2).
  #   rotateY(PI / 4).
  #   translate(0, 0, 5).initTransform()
  # rightWall.material = floor.material

  # let middle: Shape = newSphere()
  # middle.transform = translation(-0.5, 1, 0.5).initTransform()
  # middle.material = initMaterial()
  # middle.material.color = color(0.1, 1, 0.5)
  # middle.material.diffuse = 0.7
  # middle.material.specular = 0.3

  # let light = newPointLight(point(-10, 10, -10), color(1, 1, 1))
  # let w = newWorld()
  # w.objects = @[floor, leftWall, rightWall, middle]
  # w.lights = @[light]

  # let cam = newCamera(400, 200, PI / 3)
  # cam.transform = view(
  #   point(0, 1.5, -5), 
  #   point(0, 1, 0), 
  #   vector(0, 1, 0)).initTransform()
  
  # let img = cam.render(w)
  # img.savePPM("out.ppm")