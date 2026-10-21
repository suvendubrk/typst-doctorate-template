#import "_guide.typ": *

#minitoc-next(true)
= Mathematics <ch:maths>

Typst writes mathematics between dollar signs. A formula with a space after the opening and before the closing dollar is a display; without, it sits in the text. This chapter covers what the template adds: numbering, page breaking, the behaviour of inline formulas, and a set of macros for physics.

== Display equations <sec:maths-display>

Displays are numbered per chapter. A label after the closing dollar makes the equation citable.

#example(```typ
The Schrödinger equation,
$ i planck partial_t ket(psi) = hat(H) ket(psi) , $ <eq:maths-schrodinger>
is cited as @eq:maths-schrodinger.
```)

Lines are separated by `\` and aligned at `&`. A multi-line display carries one number.

#example(```typ
$
  hat(H) &= sum_j (hat(S)^x_j hat(S)^x_(j+1) + hat(S)^y_j hat(S)^y_(j+1)) \
         &= 1/2 sum_j (hat(S)^+_j hat(S)^-_(j+1) + hat(S)^-_j hat(S)^+_(j+1)) .
$
```)

To leave out numbers, wrap displays in `nonumeq`; to frame one, use `boxeq`.

#example(```typ
#nonumeq[$ e^(i pi) + 1 = 0 $]
#boxeq[$ [hat(x), hat(p)] = i planck $]
```)

=== Wide formulas

Typst centres a display and pins its number to the right margin. When the two would come closer than `eq-num-gap`, the template moves the formula to the left; if even that leaves no room, the number drops to its own line below the formula, as in LaTeX.

#example(```typ
$ Z = sum_(n=0)^infinity (-1)^n binom(2n, n) x^n y^(2n) exp(-beta E_n) cos(n theta) $
```)

=== Page breaks

By default, a numbered display of ordinary height is never split between two pages; it moves to the next page whole, because Typst would otherwise print its number on both pieces. Only displays taller than `eq-break-height` may split. To let one particular display split at its line breaks, wrap it in `breakeq`. Its number is then drawn once, next to its last line.

The choice can also be made for the whole document: with `eq-break: true` in `conf`, every numbered display may split in this way, and `nobreakeq` keeps a single one whole.

#example(```typ
#breakeq[$
  f(x) &= a_0 + a_1 x + a_2 x^2 + a_3 x^3 \
       &quad + a_4 x^4 + a_5 x^5 + a_6 x^6 + dots
$ <eq:maths-long>]
#nobreakeq[$
  g(x) &= b_0 + b_1 x \
       &quad + b_2 x^2 + dots
$]
```)

== Inline formulas <sec:maths-inline>

Formulas in running text are kept on the line grid: a subscript, a ket or a small fraction does not push its line away from the next, so a paragraph full of notation keeps even spacing. Only a formula that reaches far above or below the line, such as a stacked fraction with scripts, opens up its own line by the necessary amount (`inline-reach`).

#example(```typ
A state $ket(psi_n)$ with energy $E_n = planck omega (n + 1/2)$ and
amplitude $braket(phi, psi)$ keeps the line spacing of the text, while
$display(sum_(k=1)^N 1/k^2)$ makes room for itself.
```)

In running text, brackets keep the size of the text instead of stretching around their content (`inline-compact`). To make one bracket enclose its content in full, give it an explicit size:

#example(```typ
Compare $(sqrt(binom(2s, q)))^N$ with $lr(size: #100%, (sqrt(binom(2s, q))))^N$.
```)

== Notation for physics <sec:maths-physics>

#example(```typ
$ ket(psi), quad bra(phi), quad braket(phi, psi), quad
  braket(phi, hat(O), psi), quad expval(hat(O)), quad
  dket(rho), quad dbra(rho), quad bigO(t^(-1)) $
```)

#reftable(
  columns: (auto, 1fr),
  header: ([Macro], [Result]),
  [`ket(x)`, `bra(x)`], [Dirac kets and bras, with bars and angles of matching height.],
  [`braket(a, b)`, `braket(a, O, b)`], [Overlap and matrix element.],
  [`expval(x)`], [Expectation value $expval(x)$.],
  [`dket(x)`, `dbra(x)`], [Vectorised states, $dket(rho)$.],
  [`bigO(x)`], [Order symbol with an upright O.],
  [`cal(A)`], [Calligraphic letters from STIX Two Math, $cal(A) cal(L) cal(R)$.],
  [`ox`, `oplus`, `oxbig`, `oplusbig`], [Tensor product and direct sum, $a ox b$, $a oplus b$.],
)

These live in `template/thesis.typ` (Dirac notation) and `meta.typ` (project macros). New macros belong in `meta.typ`, where every chapter sees them (@sec:internals-macros).

== Sums and products <sec:maths-sums>

In a display, Typst stacks the limits of a sum above and below the sign. A chapter that starts with `#show: compact-sums` sets them beside the sign instead, which keeps dense equations flat. Single sums can still be stacked with `limits()`.

#example(```typ
#show: compact-sums
$ sum_(j=1)^N hat(S)^z_j quad "vs." quad limits(sum)_(j=1)^N hat(S)^z_j $
```, side: true)

A long condition under a sum is split over lines with `substack`. When it is still wider than the sign, `smashop` lets it hang under the neighbouring terms instead of pushing them away (LaTeX's `\smashoperator`). For a product, pass `op: $limits(product)$`.

#example(```typ
$ x + limits(sum)_(substack(i < j, i\, j in {alpha^((q))})) l_(i j)
  quad "vs." quad
  x + #smashop($limits(sum)_(substack(i < j, i\, j in {alpha^((q))}))$) l_(i j) $
```)

Matched braces and bars normally stretch around their content, so a set with a superscript such as ${alpha^((q))}$ grows taller than its surroundings. A chapter with `#show: flush-sets` draws braces around simple content, and the bars of a set's size, at their natural height. Braces around fractions or big operators still stretch.

#example(```typ
$ limits(sum)_(i in {alpha^((q))}) abs({beta^((p))}) $
#[#show: flush-sets
$ limits(sum)_(i in {alpha^((q))}) abs({beta^((p))}) $]
```, side: true)

== Fine spacing <sec:maths-spacing>

#reftable(
  columns: (auto, auto, 1fr),
  header: ([Macro], [Width], [Use]),
  [`neg`], [$-1 slash 6$ em], [Negative thin space, TeX's `\!`.],
  [`neg2`], [$-1 slash 3$ em], [Larger negative space.],
  [`tightx`], [$-0.08$ em], [Hair-line tightening.],
  [`wide`], [$0.6$ em], [Space between a formula and its condition.],
)
