import std / [math, os, osproc, strformat]
import pkg / chroma

export chroma

{.push inline.}
#*****************************************************************************#
#                                                                             #
#   Vector and real posiotion with procedures                                 #
#                                                                             #
#*****************************************************************************#
type
  Vec* = tuple
    x, y: float
  RealPos* = tuple
    x, y: float

proc initVec*(a, b: RealPos): Vec =
  return (x: b.x - a.x, y: b.y - a.y)

proc `*`*(v: Vec; f: float): Vec =
  return (x: v.x * f, y: v.y * f)

proc `*`*(f: float, v: Vec): Vec =
  return `*`(v, f)

proc `+`*(pos: RealPos; v: Vec): RealPos =
  return (x: pos.x + v.x, y: pos.y + v.y)


#*****************************************************************************#
#                                                                             #
#   Interval and 2D-Interval with nagation and interpolation functions        #
#                                                                             #
#*****************************************************************************#
type
  Interval* = tuple
    a, b: float
  Interval2d* = tuple
    x, y: Interval

proc `-`*(interval: Interval): Interval =
  return (a: interval.b, b: interval.a)

proc interpolate*(interval: Interval, factor: float): float =
  ## Classical interpolation of an interval
  assert 0 <= factor and factor <= 1
  return (interval.b - interval.a) * factor + interval.a

proc pixelInterpolate*(interval: Interval; pixelCount, pixel: int): float =
  ## interval width / number of pixels * current pixel + lower bound
  assert pixel < pixelcount and pixel >= 0 and pixelCount > 0
  return (interval.b - interval.a) / pixelCount.float * pixel.float + interval.a

proc calcCenter*(interval: Interval2d): RealPos =
  return (x: interval.x.interpolate(0.5), y: interval.y.interpolate(0.5))

proc adjust*(currInterval: Interval2d; vanishingPoint: RealPos; ratio: float): Interval2d =
  let
    currCenter = calcCenter(currInterval)
    adjustedCenter = vanishingPoint + initVec(vanishingPoint, currCenter) * ratio

    currIntervalLens = (x: abs(currInterval.x.b - currInterval.x.a), y: abs(currInterval.y.b - currInterval.y.a))
    adjustedIntervalLens = (x: currIntervalLens.x * ratio, y: currIntervalLens.x * ratio)

  result.x = (a: adjustedCenter.x - adjustedIntervalLens.x / 2, b: adjustedCenter.x + adjustedIntervalLens.x / 2)
  result.y = (a: adjustedCenter.y - adjustedIntervalLens.y / 2, b: adjustedCenter.y + adjustedIntervalLens.y / 2)


#*****************************************************************************#
#                                                                             #
#   Position and Interval related to image pixels                             #
#                                                                             #
#*****************************************************************************#
type
  PixelPos* = tuple
    x, y: int
  PixelDim* = tuple
    x, y: int


#*****************************************************************************#
#                                                                             #
#   Packing object to share information more easily and compact               #
#                                                                             #
#*****************************************************************************#
type
  ImageDim* = object
    real*: Interval2d
    pixel*: PixelDim
  Ratio* = range[0.0..1.0]
  ZoomInfo* = object
    vanishingPoint*: RealPos
    ratio*: Ratio
    frameCount*: Positive

proc adjust*(imgDim: ImageDim; vanishingPoint: RealPos; ratio: float): ImageDim =
  result.pixel = imgDim.pixel
  result.real  = imgDim.real.adjust(vanishingPoint, ratio)

proc adjust*(imgDim: ImageDim; zoomInfo: Zoominfo): ImageDim =
  result.pixel = imgDim.pixel
  result.real  = imgDim.real.adjust(zoomInfo.vanishingPoint, zoomInfo.ratio)


#*****************************************************************************#
#                                                                             #
#   Color palette creater funtion                                             #
#                                                                             #
#*****************************************************************************#
type
  Direction* = enum
    Clockwise, CounterClockwise
  Degree* = range[0.0..360.0]
  Palette* = seq[Color]

proc makeLinPalette*(length: Positive; times: Positive = 1; offset: Degree = 0.0; lastBlack: bool = true; direction: Direction = CounterClockwise): Palette =
  result = newSeqOfCap[Color](length)
  var x: float
  var setX: proc(x: var float; i: int)

  # The direction needs to be checked once!
  {.pop inline.}
  if direction == Clockwise:
    setX = proc(x: var float; i: int) = x = float(length-1-i)
  else:
    setX = proc(x: var float; i: int) = x = float(i)
  {.push inline.}

  for i in 0..<length:
    x.setX(i)

    var h = ((times * 360) / length * x + offset) mod Degree.high

    result.add color(hsl(h, 100, 50))
  if lastBlack:
    result[^1] = color(0, 0, 0)

#[
proc makeLogPalette(length: Positive; times: Positive = 1; offset: Degree = 0.0; lastBlack: bool = true; direction: Direction = CounterClockwise): seq[Color] =
  #logPalette: seq[ColorHSL] = collect:
  #  var c = 300
  #  for i in 0..maxIter:
  #    var x = (maxIter-i) / c
  #    var h = exp(x) / exp(maxIter/c) * 240
  #    if i < maxIter:
  #      hsl(h, 100, 50)
  #    else:
  #      hsl(0, 0, 0)
  discard
]#


#*****************************************************************************#
#                                                                             #
#   Color palette creater funtion                                             #
#                                                                             #
#*****************************************************************************#
proc clearDir*(dir: string) =
  removeDir(dir)
  createDir(dir)


#*****************************************************************************#
#                                                                             #
#   Convenience procedures and templates                                      #
#                                                                             #
#*****************************************************************************#
template withProgress*(showProgress: bool; i: int; body: untyped) =
  if showProgress:
    stdout.write(fmt"Calculating Frame {i:03}: ")
    stdout.flushFile()
  body
  if showProgress:
    stdout.write("Done\n")

proc framesToVideo*(frameDir, outputName: string; frameDuration_ms: int) =
  #ffmpeg -i mandelbrot_frame_%03d.png -filter:v fps=13 video.gif
  discard execProcess("ffmpeg", args = ["-i", fmt"{frameDir}/mandelbrot_frame_%03d.png", "-filter:v", fmt"fps={1000/frameDuration_ms}", outputName], options={poUsePath})

{.pop.}
