import unittest
import lmx

suite "cubes":
  test "a ray intersects a cube":
    let 
      c = cube()
      cases = @[
        (point(5, 0.5, 0), vector(-1, 0, 0), 4.0, 6.0)]#,
        #(point(-5, 0.5, 0), vector(1, 0, 0), 4.0, 6.0),
        #(point(0.5, 5, 0), vector(0, -1, 0), 4.0, 6.0),
        #(point(0.5, -5, 0), vector(0, 1, 0), 4.0, 6.0),
        #(point(0.5, 0, 5), vector(0, 0, 1), 4.0, 6.0),
        #(point(0, 0.5, 0), vector(0, 0, 1), -1.0, 1.0)]
    for t in cases:
      let 
        (origin, direction, t1, t2) = t
        r = ray(origin, direction)
        xs = local_intersect(c, r)
      check(len(xs) == 2)
      check(xs[0].t == t1)
      check(xs[1].t == t2)        
        