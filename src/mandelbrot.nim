import std/[strformat, os, math, complex, sugar, threadpool, cpuinfo]
import pixie, chroma
import utils

const
  pixelDim = (x: 1000, y: 1000)
  viewarea: Interval2d = (x: (-2.02, 0.48), y: (-1.25, 1.25))
  blocksize = 10
  maxIter = 10_000

  frames = 300
  ratio = 0.9
  #target = (x: -0.4445, y: 0.5574)
  #target = (x: -0.16303932481824 , y: 1.03432043626692)
  #target = (x: -0.1735589665283 , y: 0.6592712575321)
  target = (x: -0.17355903956768, y:  0.65927049566959)
  frameDir = "frames"

const
  linPalette: seq[ColorHSL] = collect:
    for i in 0..maxIter:
      let
        h = 240/maxIter*(maxIter-i).float32
      if i < maxIter:
        hsl(h, 100'f32, 50'f32)
      else:
        hsl(0'f32, 0'f32, 0'f32)
  linPalette10: seq[ColorHSL] = collect:
    for i in 0..maxIter:
      let
        h = (10*360)/maxIter*(maxIter-i).float32 + 240
      if i < maxIter:
        hsl(h mod 360.0 , 100'f32, 50'f32)
      else:
        hsl(0'f32, 0'f32, 0'f32)
  linPalette50: seq[ColorHSL] = collect:
    for i in 0..maxIter:
      let
        h = (50*360)/maxIter*(maxIter-i).float32 + 240
      if i < maxIter:
        hsl(h mod 360.0 , 100'f32, 50'f32)
      else:
        hsl(0'f32, 0'f32, 0'f32)
  logPalette: seq[ColorHSL] = collect:
    var c = 300
    for i in 0..maxIter:
      var x = (maxIter-i) / c
      var h = exp(x) / exp(maxIter/c) * 240
      if i < maxIter:
        hsl(h, 100'f32, 50'f32)
      else:
        hsl(0'f32, 0'f32, 0'f32)

  palette = linPalette50

setMaxPoolSize(countProcessors())

proc calcPixel(p: PixelPos; imgDim: ImageDim; maxIter: int): int =
  let
    c = complex(
        pixelInterpolate( imgDim.real.x, imgDim.pixel.x, p.x),
        pixelInterpolate(-imgDim.real.y, imgDim.pixel.y, p.y)
    )
  var
    z = complex(0.0, 0.0)
    iteration = 0
  
  while abs(z) < 2 and iteration < maxIter:
    z = z*z + c
    iteration.inc
  return iteration


proc calcRows(starty, endy: int; data: ptr Image; imgDim: ImageDim; maxIter: int) {.thread.} =
  for y in starty..<endy:
    for x in 0..<imgDim.pixel.x:
      data[][x,y] = palette[calcPixel((x,y), imgDim, maxIter)]


proc calcImage(imgDim: ImageDim; blocksize: int; maxIter: int): Image =
  result = newImage(imgDim.pixel.x, imgDim.pixel.y)
  for i in 0 ..< int(imgDim.pixel.y/blocksize):
    spawn calcRows(i*blocksize, (i+1)*blocksize, addr result, imgDim, maxIter)
  sync()


removeDir(frameDir)
createDir(frameDir)

var imgDim = ImageDim(real: viewarea, pixel: pixelDim)

for i in 0..<frames:
  stdout.write(fmt"Calculating Frame {i:03}: ")
  stdout.flushFile()
  let img = calcImage(imgDim, blocksize, maxIter)
  img.writeFile(fmt"./{frameDir}/mandelbrot_frame_{i:03}.png")
  stdout.write("Done\n")

  imgDim = imgDim.adjust(target, ratio)
    
