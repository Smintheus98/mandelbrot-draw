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


# Tasks

task runfast, "compile with optimal options":
  exec """nim c -r -d:release -d:danger -d:flto --passC:"-O3" --passL:"-O3" --passL:"-flto" -o:"bin/mandelbrot" src/mandelbrot.nim"""
