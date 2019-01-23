import os, math, "lmx"

proc color*(r: Ray, world: seq[Sphere]): Vec3 =
    # var t = hit_sphere((0.0, 0.0, -1.0), 0.5, r)
    var hit: Hit;
    if hit(world, r, 0.0, 20000.0, hit):
        return 0.5 * (x: hit.normal.x + 1, y: hit.normal.y + 1, z: hit.normal.z + 1)
    # no hits, just render the background gradient
    let unit_direction = r.direction.normalize()
    let t = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - t) * (x: 1.0, y: 1.0, z: 1.0) + t * (x: 0.5, y: 0.7, z: 1.0)

let 
    file = "out.ppm"
    nx = 800
    ny = 400
    lower_left_corner: Vec3 = (-2.0, -1.0, -1.0)
    horizontal: Vec3 = (4.0, 0.0, 0.0)
    vertical: Vec3 = (0.0, 2.0, 0.0)
    origin: Vec3 = (0.0, 0.0, 0.0)
    world = @[
        (center: (0.0, 0.0, -1.0), radius: 0.5),
        (center: (0.0, -100.5, -1.0), radius: 100.0)]
    
if fileExists(file): 
    removeFile(file)

let f = open(file, fmWrite)
writeLine(f, "P3")
writeLine(f, nx, " ", ny)
writeLine(f, 255)

for j in countdown(ny - 1, 0):
    for i in countup(0, nx - 1):
        let 
            u = float(i) / float(nx)
            v = float(j) / float(ny)
            r: Ray = (origin, lower_left_corner + u * horizontal + v * vertical)
            p = r.p(2.0)
            col = color(r, world)
            ir = int(255.99 * col[0])
            ig = int(255.99 * col[1])
            ib = int(255.99 * col[2])
        writeLine(f, ir, " ", ig, " ", ib)