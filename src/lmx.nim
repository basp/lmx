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
  let cam = newCamera(400, 400, 0.785)
  cam.transform = view(
    point(-6, 6, -10),
    point(6, 0, 6),
    vector(-0.45, 1, 0)).initTransform()

  let l1 = newPointLight(point(50, 100, -50), color(1, 1, 1))
  let l2 = newPointLight(point(-400, 50, -10), color(0.2, 0.2, 0.2))

  var whiteMaterial = initMaterial()
  whiteMaterial.color = color(1, 1, 1)
  whiteMaterial.diffuse = 0.7
  whiteMaterial.ambient = 0.1
  whiteMaterial.specular = 0.0
  whiteMaterial.reflective = 0.1

  var blueMaterial = whiteMaterial
  blueMaterial.color = color(0.537, 0.831, 0.914)

  var redMaterial = whiteMaterial
  redMaterial.color = color(0.941, 0.322, 0.388)

  var purpleMaterial = whiteMaterial
  purpleMaterial.color = color(0.373, 0.404, 0.550)

  let standardTransform =
    identityMatrix.
      translate(1, -1, 1).
      scale(0.5, 0.5, 0.5)

  let largeObject = standardTransform.scale(3.5, 3.5, 3.5)
  let mediumObject = standardTransform.scale(3, 3, 3)
  let smallObject = standardTransform.scale(2, 2, 2)
  
  let plane = newPlane()
  plane.material.color = color(1, 1, 1)
  plane.material.ambient = 1
  plane.material.diffuse = 0
  plane.material.specular = 0
  plane.transform = identityMatrix.
    rotateX(math.PI / 2).
    translate(0, 0, 500).initTransform()

  let sphere = newSphere()
  sphere.material.color = color(0.373, 0.404, 0.550)
  sphere.material.diffuse = 0.2
  sphere.material.ambient = 0
  sphere.material.specular = 1.0
  sphere.material.shininess = 200
  sphere.material.reflective = 0.7
  sphere.material.transparency = 0.7
  sphere.material.refractiveIndex = 1.5
  sphere.transform = largeObject.initTransform()

  let cube1 = newCube()
  cube1.material = whiteMaterial
  cube1.transform = mediumObject.
    translate(4, 0, 0).initTransform()

  let cube2 = newCube()
  cube2.material = blueMaterial
  cube2.transform = largeObject.
    translate(8.5, 1.5, -0.5).initTransform()

  let cube3 = newCube()
  cube3.material = redMaterial
  cube3.transform = largeObject.
    translate(0, 0, 4).initTransform()

  let cube4 = newCube()
  cube4.material = whiteMaterial
  cube4.transform = smallObject.
    translate(4, 0, 4).initTransform()

  let cube5 = newCube()
  cube5.material = purpleMaterial
  cube5.transform = mediumObject.
    translate(7.5, 0.5, 4).initTransform()

  let cube6 = newCube()
  cube6.material = whiteMaterial
  cube6.transform = mediumObject.
    translate(-0.25, 0.25, 8).initTransform()

  let cube7 = newCube()
  cube7.material = blueMaterial
  cube7.transform = largeObject.
    translate(4, 1, 7.5).initTransform()

  let cube8 = newCube()
  cube8.material = redMaterial
  cube8.transform = mediumObject.
    translate(10, 2, 7.5).initTransform()

  let cube9 = newCube()
  cube9.material = whiteMaterial
  cube9.transform = smallObject.
    translate(8, 2, 12).initTransform()

  let cube10 = newCube()
  cube10.material = whiteMaterial
  cube10.transform = smallObject.
    translate(20, 1, 9).initTransform()

  let cube11 = newCube()
  cube11.material = blueMaterial
  cube11.transform = largeObject.
    translate(-0.5, -5, 0.25).initTransform()

  let cube12 = newCube()
  cube12.material = redMaterial
  cube12.transform = largeObject.
    translate(4, -4, 0).initTransform()

  let cube13 = newCube()
  cube13.material = whiteMaterial
  cube13.transform = largeObject.
    translate(8.5, -4, 0).initTransform()

  let cube14 = newCube()
  cube14.material = whiteMaterial
  cube14.transform = largeObject.
    translate(0, -4, 4).initTransform()

  let cube15 = newCube()
  cube15.material = purpleMaterial
  cube15.transform = largeObject.
    translate(-0.5, -4.5, 8).initTransform()

  let cube16 = newCube()
  cube16.material = whiteMaterial
  cube16.transform = largeObject.
    translate(0, -8, 4).initTransform()

  let cube17 = newCube()
  cube17.material = whiteMaterial
  cube17.transform = largeObject.
    translate(-0.5, -8.5, 8).initTransform()

  let w = newWorld()
  w.objects = @[
    Shape(plane),
    Shape(sphere),
    Shape(cube1),
    Shape(cube2),
    Shape(cube3),
    Shape(cube4),
    Shape(cube5),
    Shape(cube6),
    Shape(cube7),
    Shape(cube8),
    Shape(cube9),
    Shape(cube10),
    Shape(cube11),
    Shape(cube12),
    Shape(cube13),
    Shape(cube14),
    Shape(cube15),
    Shape(cube16),
    Shape(cube17)]

  w.lights = @[l1, l2]
  
  let img = cam.render(w)
  img.savePPM("out.ppm")