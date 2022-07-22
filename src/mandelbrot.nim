import std / [strformat, complex, threadpool, cpuinfo]
import pkg / pixie
import utils

setMaxPoolSize(countProcessors())

proc calcPixel(p: PixelPos; imgDim: ImageDim; maxIter: int): int {.inline.} =
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
  return iteration-1


proc calcRows(starty, endy: int; data: ptr Image; imgDim: ImageDim; maxIter: int; palette: Palette) {.thread, inline.} =
  for y in starty..<endy:
    for x in 0..<imgDim.pixel.x:
      data[][x,y] = palette[calcPixel((x,y), imgDim, maxIter)]


proc calcImage(imgDim: ImageDim; blocksize, maxIter: int; palette: Palette): Image {.inline.} =
  result = newImage(imgDim.pixel.x, imgDim.pixel.y)
  for i in 0 ..< int(imgDim.pixel.y/blocksize):
    spawn calcRows(i*blocksize, (i+1)*blocksize, addr result, imgDim, maxIter, palette)
  sync()


proc calcFrames(zoomInfo: ZoomInfo; frameDir: string; imgDim: ImageDim; blocksize, maxIter: int; palette: Palette; showProgress: bool = true) {.inline.} =
  frameDir.clearDir
  var imgDim = imgDim

  for i in 0..<zoomInfo.frameCount:
    withProgress showProgress, i:
      let img = calcImage(imgDim, blocksize, maxIter, palette)
      img.writeFile(fmt"./{frameDir}/mandelbrot_frame_{i:03}.png")
    imgDim = imgDim.adjust(zoomInfo)


proc drawImage(filename: string; imgDim: ImageDim; blocksize, maxIter: int; palette: Palette) =
  let img = calcImage(imgDim, blocksize, maxIter, palette)
  img.writeFile(filename)


proc drawVideo(filename: string; frameDuration: int; zoomInfo: ZoomInfo; frameDir: string; imgDim: ImageDim; blocksize, maxIter: int; palette: Palette; showProgress: bool = true) =
  calcFrames(zoomInfo, frameDir, imgDim, blocksize, maxIter, palette, showProgress)
  frameDir.framesToVideo(filename, frameDuration)

let
  maxIter = 10_000
  blocksize = 10
  frameDir = "frames"

  palette = makeLinPalette(maxIter, 50, 240, true, Clockwise)

  imgDim = ImageDim(
    real: (x: (-2.02, 0.48), y: (-1.25, 1.25)),
    pixel: (x: 1000, y: 1000),
  )

  zoomInfo = ZoomInfo(
    #vanishingPoint: (x: -0.4445, y: 0.5574),
    #vanishingPoint: (x: -0.16303932481824 , y: 1.03432043626692),
    #vanishingPoint: (x: -0.1735589665283 , y: 0.6592712575321),
    vanishingPoint: (x: -0.17355903956768, y:  0.65927049566959),
    ratio: 0.9,
    frameCount: 300,
  )

doAssert imgDim.pixel.y mod blocksize == 0, "`blocksize` must be a devisor of `imgDim.pixel.y`"

#calcImage(imgDim, blocksize, maxIter, palette).writeFile("mandelbrot.png")
calcFrames(zoomInfo, frameDir, imgDim, blocksize, maxIter, palette, true)

