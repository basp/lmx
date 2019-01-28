import unittest, pkglmx/core

suite "lights":
    test "a point light has a position and intensity":
        let
            intensity = color(1, 1, 1)
            pos = point(0, 0, 0)
            light = point_light(pos, intensity)
        check(light.position == pos)
        check(light.intensity == intensity)