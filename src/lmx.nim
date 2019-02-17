import math, sequtils

import pkglmx/geometry,
       pkglmx/transform,
       pkglmx/colors,
       pkglmx/world,
       pkglmx/canvas,
       pkglmx/camera

export geometry,
       transform,
       colors,
       world,
       canvas,
       camera

when isMainModule:
  let floor: Shape = newSphere()
  floor.transform = scaling(10, 0.01, 10).initTransform()
  floor.material = initMaterial()
  floor.material.color = color(1, 0.9, 0.9)
  floor.material.specular = 0

  let leftWall: Shape = newSphere()
  leftWall.transform = identityMatrix.
    scale(10, 0.01, 10).
    rotateX(PI / 2).
    rotateY(-PI / 4).
    translate(0, 0, 5).initTransform()
  leftWall.material = floor.material

  let rightWall: Shape = newSphere()
  rightWall.transform = identityMatrix.
    scale(10, 0.01, 10).
    rotateX(PI / 2).
    rotateY(PI / 4).
    translate(0, 0, 5).initTransform()
  rightWall.material = floor.material

  let middle: Shape = newSphere()
  middle.transform = translation(-0.5, 1, 0.5).initTransform()
  middle.material = initMaterial()
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3

  let light = newPointLight(point(-10, 10, -10), color(1, 1, 1))
  let w = newWorld()
  w.objects = @[floor, leftWall, rightWall, middle]
  w.lights = @[light]

  let cam = newCamera(400, 200, PI / 3)
  cam.transform = view(
    point(0, 1.5, -5), 
    point(0, 1, 0), 
    vector(0, 1, 0)).initTransform()
  
  let img = cam.render(w)
  img.savePPM("out.ppm")