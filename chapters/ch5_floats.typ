#import "_guide.typ": *

#minitoc-next(true)
= Figures, tables and boxes <ch:floats>

== Figures <sec:floats-figures>

Figures are numbered per chapter ("Figure 5.1") and float to the top of a page by default, as in LaTeX. Images can be SVG, PNG, JPEG or PDF.

#code(```typ
#figure(
  image("../images/ch5/spectrum.svg", width: 80%),
  caption: [*Spectrum of the model.* Bold text opens the caption.],
) <fig:floats-spectrum>
```)

A figure that must stay where it is written takes `placement: none`. Captions are set small, justified and left aligned; @sec:internals-recipes shows where to change that.

#example(```typ
#figure(
  rect(width: 60%, height: 1.6cm, fill: luma(90%)),
  caption: [A figure kept in place.],
  placement: none,
) <fig:floats-demo>
See @fig:floats-demo.
```)

Several panels share one number and caption with `subfigure`. The panels are labelled (a), (b), ... and cannot be cited one by one.

#example(```typ
#subfigure(
  rect(width: 100%, height: 1.2cm, fill: luma(88%)),
  rect(width: 100%, height: 1.2cm, fill: luma(80%)),
  caption: [Two related panels.],
)
```)

== Tables <sec:floats-tables>

`btable` draws a table in the style of LaTeX's `booktabs`: no vertical rules, heavy rules at the top and bottom, a light rule under the header. Rows can be tinted with `highlight` (1 is the first body row), and `inset` narrows the cells of a wide table.

#example(```typ
#figure(
  btable(
    columns: 3,
    header: ([Model], [Symmetry], [Method]),
    highlight: (2,),
    [XXX], [$frak(s u)(2)$], [Bethe ansatz],
    [XXZ], [$U_q (frak(s u)(2))$], [Bethe ansatz],
    [Ising], [$bb(Z)_2$], [Free fermions],
  ),
  caption: [Some integrable spin chains.],
) <tab:floats-chains>
```)

Tables in a figure are numbered "Table 5.1" independently of figures. Unlike images, they stay in place and may break across pages, repeating their header row.

== Boxes <sec:floats-boxes>

`concept` (alias `highlight-box`) sets a key idea in a tinted box with a bar in the accent colour. Equations inside keep the full width, so their numbers align with the others.

#example(```typ
#concept(title: "Main result")[
  The model is integrable for every value of the coupling,
  $ [hat(H), hat(Q)_n] = 0 . $
]
#concept(color: rgb("#7b2d8b"))[A box in another colour.]
```)

== Placeholders <sec:floats-placeholder>

While a figure is missing, `placeholder-fig` (from `meta.typ`) reserves its space:

#example(```typ
#figure(placeholder-fig(height: 1.5cm), caption: [To be drawn.], placement: none)
```)

== Flip-book <sec:floats-flipbook>

A thesis can carry a small animation in the corner of its pages, visible when the book is flipped through. `flipbook` takes a function from the page number to the content of the corner cell. `meta.typ` contains a moving dot as a demonstration:

#code(```typ
// meta.typ
#let demo-flip(n) = {
  let t = calc.rem(n, 16) / 16
  let x = 100% * calc.abs(2 * t - 1)
  box(width: 100%, height: 100%,
    place(left + horizon, dx: x, circle(radius: 2.5pt, fill: rgb("#5A6C80"))))
}
#let conf = thesis.with(..., flipbook: demo-flip)

// frames from image files instead:
//   flipbook: n => image("images/frames/" + str(n) + ".png")
```)
