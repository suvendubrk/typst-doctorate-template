#import "../meta.typ": *

#show: compact-sums
#show: flush-sets

= A second chapter <ch:second>

Equations number per chapter, and references to them stay correct from
anywhere: @eq:example-long lives in @ch:example.

$
  Z = sum_({sigma}) exp(-beta H[sigma]), quad
  limits(sum)_(substack(i in {alpha^((q))}, j in {beta^((p))})) J_(i j) ket(psi)
$ <eq:second-partition>

#btable(
  columns: 3,
  header: ([Model], [Symmetry], [Solved by]),
  [XXX], [$frak(s u)(2)$], [Bethe ansatz],
  [XXZ], [$U_q (frak(s u)(2))$], [Bethe ansatz],
)
