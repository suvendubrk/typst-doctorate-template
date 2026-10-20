#import "../meta.typ": *

#minitoc-next(true)
= An example chapter <ch:example>

// --- sections (each in its own file) ---
== Background and motivation
We set the historical and physical context.

=== The Yang--Baxter equation
A consistency condition for factorised scattering @yang-1967-article-deltainteraction @baxter-1982-book-exactlysolved:
$ R_(12)(u) R_(13)(u + v) R_(23)(v) = R_(23)(v) R_(13)(u + v) R_(12)(u) $

#concept[
  The Yang--Baxter equation is the single organising principle behind every
  construction in Part I.
]

=== Transfer matrices
The algebraic backbone of Part I.

== Scope of this thesis
A boxed key result:
#boxeq($ [R_(12), R_(13)] + dots = 0 $)

// --- sections ---
== The reflection equation
The boundary analogue of the bulk relation, due to Sklyanin @sklyanin-1988-article-boundary:
$ R_(12) K_1 R_(21) K_2 = K_2 R_(12) K_1 R_(21) $

An unnumbered aside:
#nonumeq($ K(u) thin overline(K)(u) = 1 $)

Manual spacing: $ integral f(x) dif x quad "vs." quad integral#neg f(x)#tightx dif x $

#concept(title: "Key idea", color: rgb("#7b2d8b"))[
  At a boundary, integrability is controlled by the reflection equation rather
  than the bulk relation alone.
]


== Long equations
A numbered display wrapped in `breakeq` may split across pages at its line
breaks, with its number set once beside the last line:
#breakeq[$
  f(x) &= a_0 + a_1 x + a_2 x^2 + a_3 x^3 \
  &quad + a_4 x^4 + a_5 x^5 + a_6 x^6 \
  &quad + a_7 x^7 + a_8 x^8 + dots
$ <eq:example-long>]
See @eq:example-long and @app:example-deriv.

== A worked figure
#figure(rect(width: 6cm, height: 2.4cm, fill: luma(92%)), caption: [A placeholder figure.])

#subfigure(
  rect(width: 100%, height: 2cm, fill: luma(90%)),
  rect(width: 100%, height: 2cm, fill: luma(85%)),
  caption: [Two related panels.],
)

// --- appendices for this chapter ---
#chapter-appendix("Detailed derivation of the R-matrix", id: <app:example-deriv>)[
  Expanding the consistency condition to low order,
  $ R(u) = 1 + u thin r + O(u^2), $
  and collecting the next order gives
  $ r_(12) r_(13) + r_(12) r_(23) + r_(13) r_(23) = 0 . $
]

#chapter-appendix("Conventions and notation")[
  Traces are taken over the auxiliary space,
  $ tau(u) = "tr"_0 T_0(u) . $
]
