# mandelbrot-draw
Drawing mandelbrot set with zoom in

# Performance log

<table>
  <tr>
    <td> Date </td>
    <td> Branch </td>
    <td> Specification </td>
    <td> Time </td>
    <td> Notes </td>
  </tr>
  <tr>
    <td> 2022-07-10 </td>
    <td> main </td>
    <td>
      <ul>
        <li> vanishing point: $-0.17355903956768 + i \cdot 0.65927049566959$ </li>
        <li> coloring: linear, $50$ times </li>
        <li> iterations: $10.000$ </li>
        <li> frames: $300$ </li>
        <li> zoom ratio: $0.9$ </li>
        <li> threads: $16$ </li>
        <li> image resolution: $1000 \times 1000$ pixel </li>
      </ul>
    </td>
    <td> $\approx 29$ min. </td>
    <td>
      <ul>
        <li> Dirty code </li>
        <li> Color Palettes constant </br> (compile time) </li>
      </ul>
    </td>
  </tr>
  <tr>
    <td> 2022-07-22 </td>
    <td> main </td>
    <td>
      <ul>
        <li> vanishing point: $-0.17355903956768 + i \cdot 0.65927049566959$ </li>
        <li> coloring: linear, $50$ times </li>
        <li> iterations: $10.000$ </li>
        <li> frames: $300$ </li>
        <li> zoom ratio: $0.9$ </li>
        <li> threads: $16$ </li>
        <li> image resolution: $1000 \times 1000$ pixel </li>
      </ul>
    </td>
    <td> $\approx 30.02$ min. </td>
    <td>
      <ul>
        <li> Clean code </li>
        <li> Color Palettes calculated at runtime </li>
      </ul>
    </td>
  </tr>
</table>
