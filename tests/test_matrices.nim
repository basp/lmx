import unittest, math, lmx

suite "matrices":
    test "constructing and inspecting a 4x4 matrix":
        let m: Matrix[4] = [[1.0, 2.0, 3.0, 4.0],
                            [5.5, 6.5, 7.5, 8.5],
                            [9.0, 10.0, 11.0, 12.0],
                            [13.5, 14.5, 15.5, 16.5]]
        check(m[0, 0] == 1.0)
        check(m[0, 3] == 4.0)
        check(m[1, 0] == 5.5)
        check(m[1, 2] == 7.5)
        check(m[2, 2] == 11.0)
        check(m[3, 0] == 13.5)
        check(m[3, 2] == 15.5)

    test "a 2x2 matrix ought to be representable":
        let m: Matrix[2] = [[-3.0, 5.0],
                                [1.0, -2.0]]
        check(m[0, 0] == -3.0)
        check(m[0, 1] == 5.0)
        check(m[1, 0] == 1.0)
        check(m[1, 1] == -2.0)

    test "a 3x3 matrix ought to be representable":
        let m: Matrix[3] = [[-3.0, 5.0, 0.0],
                                [1.0, -2.0, -7.0],
                                [0.0, 1.0, 1.0]]
        check(m[0, 0] == -3.0)
        check(m[1, 1] == -2.0)
        check(m[2, 2] == 1.0)

    test "matrix equality with identical matrices":
        let a: Matrix[4] = [[1.0, 2.0, 3.0, 4.0],
                            [5.0, 6.0, 7.0, 8.0],
                            [9.0, 8.0, 7.0, 6.0],
                            [5.0, 4.0, 3.0, 2.0]]
        let b: Matrix[4] = [[1.0, 2.0, 3.0, 4.0],
                            [5.0, 6.0, 7.0, 8.0],
                            [9.0, 8.0, 7.0, 6.0],
                            [5.0, 4.0, 3.0, 2.0]]
        check(a =~ b)

    test "matrix equality with different matrices":
        let a: Matrix[4] = [[1.0, 2.0, 3.0, 4.0],
                            [5.0, 6.0, 7.0, 8.0],
                            [9.0, 8.0, 7.0, 6.0],
                            [5.0, 4.0, 3.0, 2.0]]
        let b: Matrix[4] = [[2.0, 3.0, 4.0, 5.0],
                            [6.0, 7.0, 8.0, 9.0],
                            [8.0, 7.0, 6.0, 5.0],
                            [4.0, 3.0, 2.0, 1.0]]
        check(not (a =~ b))

    test "multiplying two matrices":
        let a: Matrix[4] = [[1.0, 2.0, 3.0, 4.0],
                            [5.0, 6.0, 7.0, 8.0],
                            [9.0, 8.0, 7.0, 6.0],
                            [5.0, 4.0, 3.0, 2.0]]
        let b: Matrix[4] = [[-2.0, 1.0, 2.0, 3.0],
                            [3.0, 2.0, 1.0, -1.0],
                            [4.0, 3.0, 6.0, 5.0],
                            [1.0, 2.0, 7.0, 8.0]]
        check((a * b) =~ [[20.0, 22.0, 50.0, 48.0],
                          [44.0, 54.0, 114.0, 108.0],
                          [40.0, 58.0, 110.0, 102.0],
                          [16.0, 26.0, 46.0, 42.0]])

    test "a matrix multiplied by a tuple":
        let a: Matrix[4] = [[1.0, 2.0, 3.0, 4.0],
                            [2.0, 4.0, 4.0, 2.0],
                            [8.0, 6.0, 4.0, 1.0],
                            [0.0, 0.0, 0.0, 1.0]]
        let b: Vec4 = (1.0, 2.0, 3.0, 1.0)
        check((a * b) =~ (18.0, 24.0, 33.0, 1.0))

    test "multiplying a matrix by the identity matrix":
        let a: Matrix[4] = [[0.0, 1.0, 2.0, 4.0],
                            [1.0, 2.0, 4.0, 8.0],
                            [2.0, 4.0, 8.0, 16.0],
                            [4.0, 8.0, 16.0, 32.0]]
        check((a * identity) =~ a)

    test "transposing a matrix":
        let a: Matrix[4] = [[0.0, 9.0, 3.0, 0.0],
                            [9.0, 8.0, 0.0, 8.0],
                            [1.0, 8.0, 5.0, 3.0],
                            [0.0, 0.0, 5.0, 8.0]]
        check(transpose(a) =~ [[0.0, 9.0, 1.0, 0.0],
                            [9.0, 8.0, 8.0, 0.0],
                            [3.0, 0.0, 5.0, 5.0],
                            [0.0, 8.0, 3.0, 8.0]])

    test "transposing the identity matrix":
        let a = transpose(identity)
        check(a =~ identity)

    test "calculating the determinant of a 2x2 matrix":
        let a: Matrix[2] = [[1.0, 5.0],
                            [-3.0, 2.0]]
        check(determinant(a) =~ 17.0)

    test "a submatrix of a 3x3 matrix is a 2x2 matrix":
        let a: Matrix[3] = [[1.0, 5.0, 0.0],
                            [-3.0, 2.0, 7.0],
                            [0.0, 6.0, -3.0]]
        check(submatrix(a, 0, 2) =~ [[-3.0, 2.0], [0.0, 6.0]])

    test "a submatrix of a 4x4 matrix is a 3x3 matrix":
        let a: Matrix[4] = [[-6.0, 1.0, 1.0, 6.0],
                            [-8.0, 5.0, 8.0, 6.0],
                            [-1.0, 0.0, 8.0, 2.0],
                            [-7.0, 1.0, -1.0, 1.0]]
        check(submatrix(a, 2, 1) =~ [[-6.0, 1.0, 6.0],
                                     [-8.0, 8.0, 6.0],
                                     [-7.0, -1.0, 1.0]])

    test "calculating the minor of a 3x3 matrix":
        let a: Matrix[3] = [[-3.0, 5.0, 0.0],
                            [2.0, -1.0, -7.0],
                            [6.0, -1.0, 5.0]]
        let b = submatrix(a, 1, 0)
        check(determinant(b) =~ 25.0)
        check(minor(a, 1, 0) =~ 25.0)

    test "calculating the cofactor of a 3x3 matrix":
        let a: Matrix[3] = [[3.0, 5.0, 0.0],
                            [2.0, -1.0, -7.0],
                            [6.0, -1.0, 5.0]]
        check(minor(a, 0, 0) =~ -12.0)
        check(cofactor(a, 0, 0) =~ -12.0)
        check(minor(a, 1, 0) =~ 25)
        checK(cofactor(a, 1, 0) =~ -25.0)

    test "calculating the determinant of a 3x3 matrix":
        let a: Matrix[3] = [[1.0, 2.0, 6.0],
                            [-5.0, 8.0, -4.0],
                            [2.0, 6.0, 4.0]]
        check(cofactor(a, 0, 0) =~ 56.0)
        check(cofactor(a, 0, 1) =~ 12)
        check(cofactor(a, 0, 2) =~ -46.0)
        check(determinant(a) =~ -196.0)

    test "calculating the determinant of a 4x4 matrix":
        let a: Matrix[4] = [[-2.0, -8.0, 3.0, 5.0],
                            [-3.0, 1.0, 7.0, 3.0],
                            [1.0, 2.0, -9.0, 6.0],
                            [-6.0, 7.0, 7.0, -9.0]]
        check(cofactor(a, 0, 0) =~ 690)
        check(cofactor(a, 0, 1) =~ 447)
        check(cofactor(a, 0, 2) =~ 210)
        check(cofactor(a, 0, 3) =~ 51)
        checK(determinant(a) =~ -4071)

    test "testing an invertible matrix for invertibility":
        let a: Matrix[4] = [[6.0, 4.0, 4.0, 4.0],
                            [5.0, 5.0, 7.0, 6.0],
                            [4.0, -9.0, 3.0, -7.0],
                            [9.0, 1.0, 7.0, -6.0]]
        check(determinant(a) =~ -2120)
        check(isInvertible(a))

    test "testing a non-invertible matrix for invertibility":
        let a: Matrix[4] = [[-4.0, 2.0, -2.0, -3.0],
                            [9.0, 6.0, 2.0, 6.0],
                            [0.0, -5.0, 1.0, -5.0],
                            [0.0, 0.0, 0.0, 0.0]]
        check(determinant(a) =~ 0)
        check(not isInvertible(a))

    test "calculating the inverse of a matrix":
        let a: Matrix[4] = [[-5.0, 2.0, 6.0, -8.0],
                            [1.0, -5.0, 1.0, 8.0],
                            [7.0, 7.0, -6.0, -7.0],
                            [1.0, -3.0, 7.0, 4.0]]
        let b = inverse(a)
        check(determinant(a) =~ 532)
        check(cofactor(a, 2, 3) =~ -160)
        check(b[3, 2] =~ -160.0 / 532.0)
        check(cofactor(a, 3, 2) =~ 105)
        check(b[2, 3] =~ 105.0 / 532.0)
        check(b =~ [[0.21805, 0.45113, 0.24060, -0.04511],
                    [-0.80827, -1.45677, -0.44361, 0.52068],
                    [-0.07895, -0.22368, -0.05263, 0.19737],
                    [-0.52256, -0.81391, -0.30075, 0.30639]])

    test "calculating the inverse of another matrix":
        let a: Matrix[4] = [[8.0, -5.0, 9.0, 2.0],
                            [7.0, 5.0, 6.0, 1.0],
                            [-6.0, 0.0, 9.0, 6.0],
                            [-3.0, 0.0, -9.0, -4.0]]
        check(inverse(a) =~ [[-0.15385, -0.15385, -0.28205, -0.53846],
                             [-0.07692, 0.12308, 0.02564, 0.03077],
                             [0.35897, 0.35897, 0.43590, 0.92308],
                             [-0.69231, -0.69231, -0.76923, -1.92308]])

    test "calculating the inverse of a third matrix":
        let a: Matrix[4] = [[9.0, 3.0, 0.0, 9.0],
                            [-5.0, -2.0, -6.0, -3.0],
                            [-4.0, 9.0, 6.0, 4.0],
                            [-7.0, 6.0, 6.0, 2.0]]
        check(inverse(a) =~ [[-0.04074, -0.07778, 0.14444, -0.22222],
                             [-0.07778, 0.03333, 0.36667, -0.33333],
                             [-0.02901, -0.14630, -0.10926, 0.12963],
                             [0.17778, 0.06667, -0.26667, 0.33333]])

    test "multiplying a product by its inverse":
        let a: Matrix[4] = [[3.0, -9.0, 7.0, 3.0],
                            [3.0, -8.0, 2.0, -9.0],
                            [-4.0, 4.0, 4.0, 1.0],
                            [-6.0, 5.0, -1.0, 1.0]]
        let b: Matrix[4] = [[8.0, 2.0, 2.0, 2.0],
                            [3.0, -1.0, 7.0, 0.0],
                            [7.0, 0.0, 5.0, 4.0],
                            [6.0, -2.0, 0.0, 5.0]]
        let c = a * b
        check(c * inverse(b) =~ a)