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

proc adjust*(currInterval: Interval2d; centering: RealPos; ratio: float): Interval2d =
  let
    currCenter = calcCenter(currInterval)
    adjustedCenter = centering + initVec(centering, currCenter) * ratio

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
#   Packing object to share details about the images dimensions               #
#                                                                             #
#*****************************************************************************#
type ImageDim* = object
  real*: Interval2d
  pixel*: PixelDim
  

proc adjust*(imgDim: ImageDim; centering: RealPos; ratio: float): ImageDim =
  result.pixel = imgDim.pixel
  result.real = imgDim.real.adjust(centering, ratio)

{.pop.}
