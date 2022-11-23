import std / [sequtils]
import pkg / [chroma, pixie]
export chroma, pixie


#[ block:
  proc clip*[T](x, a, b: T): T =
    ## Clip `x` to interval [`a`,`b`]: `a <= x <= b`.
    ## Defaults to nearer border if `x` is outside of the interval
    return max(a, min(x, b))

  proc `+`*(col1, col2: ColorRGBX): ColorRGBX =
    ## Add two RGBX colors elementwise
    let
      a = (col1.a + col2.a) div 2
      r = clip(col1.r + col2.r, 0, a)
      g = clip(col1.g + col2.g, 0, a)
      b = clip(col1.b + col2.b, 0, a)
    return ColorRGBX(r: r, g: g, b: b, a: a)

  proc `+`*(img1, img2: Image): Image =
    ## add two images elementwise
    let
      w = max(img1.width, img2.width)
      h = max(img1.height, img2.height)
    result = newImage(w, h)
    for y in 0..<h:
      for x in 0..<w:
        result[x,y] = img1[x,y] + img2[x,y]

  proc `-`*(col1, col2: ColorRGBX): ColorRGBX =
    ## subtract two colors elementwise
    let
      a = (col1.a + col2.a) div 2
      r = if col2.r >= col1.r: 0'u8 else: col1.r - col2.r
      g = if col2.g >= col1.g: 0'u8 else: col1.g - col2.g
      b = if col2.b >= col1.b: 0'u8 else: col1.b - col2.b
    return ColorRGBX(r: r, g: g, b: b, a: a)

  proc `-`*(img1, img2: Image): Image =
    ## subtract two images elementwise
    let
      w = max(img1.width, img2.width)
      h = max(img1.height, img2.height)
    result = newImage(w, h)
    for y in 0..<h:
      for x in 0..<w:
        result[x,y] = img1[x,y] - img2[x,y]

  proc `*`*(factor: float; col: ColorRGBX): ColorRGBX =
    ## scale color elementwise
    let
      a = col.a
      r = clip(col.r, 0, 255)
      g = clip(col.g, 0, 255)
      b = clip(col.b, 0, 255)
    return ColorRGBX(r: r, g: g, b: b, a: a)

  proc `*`*(factor: float; img: Image): Image =
    ## scale image elementwise
    let
      w = img.width
      h = img.height
    result = newImage(w, h)
    for y in 0..<h:
      for x in 0..<w:
        result[x,y] = factor * img[x,y]
]#

type FilterKernel* = object
  size*: Natural
  data*: seq[float]

proc normalize_kernel*(k: FilterKernel): FilterKernel =
  result = k
  var norm = k.data.sum
  result.data.applyIt(it / norm)
