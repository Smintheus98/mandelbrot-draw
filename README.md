# mandelbrot-draw
Drawing mandelbrot set with zoom in

# Performance log

| Date          | Branch    | Specification                                                 | Time      | Notes                                         |
|---------------|-----------|---------------------------------------------------------------|-----------|-----------------------------------------------| 
| 2022-07-10    | main      | - vanishing point: -0.17355903956768 + i \* 0.65927049566959  | ~ 29 min  |                                               |
|               |           | - coloring: linear, 50 times                                  |           |                                               |
|               |           | - iterations: 10.000                                          |           |                                               |
|               |           | - frames: 300                                                 |           |                                               |
|               |           | - zoom ratio: 0.9                                             |           |                                               |
|               |           | - threads: 16                                                 |           |                                               |
|               |           | - image resolution: 1000x1000 pixel                           |           |                                               |
|               |           | - algorithm: iterative                                        |           |                                               |
