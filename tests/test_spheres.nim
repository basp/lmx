import unittest, math
import lmx, utils

const
  sqrt2over2 = sqrt(2.0) / 2  
  sqrt3over3 = sqrt(3.0) / 3

suite "spheres":
  test "a sphere's default transformation":
    let s = newSphere()
    check(s.transform.m =~ identityMatrix)

  test "changing a sphere's transformation":
    let 
      s = newSphere()
      t = initTransform(translation(2, 3, 4))
    s.transform = t
    check(s.transform == t)

  test "intersecting a scaled sphere with a ray":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = newSphere()
    s.transform = initTransform(scaling(2, 2, 2))
    let xs = s.intersect(r)
    check(len(xs) == 2)
    check(xs[0].t == 3)
    check(xs[1].t == 7)

  test "intersecting a translated sphere with a ray":
    let
      r = ray(point(0, 0, -5), vector(0, 0, 1))
      s = newSphere()
    s.transform = initTransform(translation(5, 0, 0))
    let xs = s.intersect(r)
    check(len(xs) == 0)

  test "the normal on a sphere at a point on the x-axis":
    let 
      s = newSphere()
      n = s.normalAt(point(1, 0, 0))
    check(n =~ vector(1, 0, 0))

  test "the normal on a sphere at a point on the y-axis":
    let
      s = newSphere()
      n = s.normalAt(point(0, 1, 0))
    check(n =~ vector(0, 1, 0))

  test "the normal on a sphere at a point on the z-axis":
    let
      s = newSphere()
      n = s.normalAt(point(sqrt3over3, sqrt3over3, sqrt3over3))
    check(n =~ vector(sqrt3over3, sqrt3over3, sqrt3over3))

  test "the normal is a normalized vector":
    let
      s = newSphere()
      n = s.normalAt(point(sqrt3over3, sqrt3over3, sqrt3over3))
    check(n =~ n.normalize())

  test "computing the normal on a translated sphere":
    let 
      s = newSphere()
      m = translation(0, 1, 0)
      p = point(0, 1.70711, -0.70711)
    s.transform = initTransform(m)
    let n = s.normalAt(point(0, 1.70711, -0.70711))
    check(n =~ vector(0, 0.70711, -0.70711))

  test "computing the normal on a transformed sphere":
    let
      s = newSphere()
      m = scaling(1, 0.5, 1) * rotation_z(PI / 5)
    s.transform = initTransform(m)
    let n = s.normalAt(point(0, sqrt2over2, -sqrt2over2))
    check(n =~ vector(0, 0.97014, -0.24254))
    
  test "a sphere has a default material":
    let 
      s = newSphere()
      m = s.material
    check(m == initMaterial())
    
  test "a sphere may be assigned a material":
    let s = newSphere()
    var m = initMaterial()    
    m.ambient = 1.0
    s.material = m
    check(s.material == m)