# Package

version       = "0.1.0"
author        = "Yannic Kitten"
description   = "Drawing mandelbrot set with zoom in"
license       = "BSD-2-Clause"
srcDir        = "src"
binDir        = "bin"
bin           = @["mandelbrot"]


# Dependencies

requires "nim >= 1.6.6"
requires "pixie"
requires "chroma"
