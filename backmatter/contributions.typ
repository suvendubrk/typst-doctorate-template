#import "../meta.typ": *

#heading(numbering: none)[Coauthor contributions]

#let me = text(weight: "bold")[YN]

// venue: journal reference, linked to the published version through `doi`.
// arxiv: preprint number, linked to its arXiv page.
#let entry(chapter, authors, venue, body, doi: none, arxiv: none) = block(above: 2.4em, below: 0pt, breakable: true)[
  #text(weight: "bold")[#chapter]
  #v(0.35em)
  #authors \
  #emph(if doi != none { link("https://doi.org/" + doi, venue) } else { venue })
  #if arxiv != none [ \ #link("https://arxiv.org/abs/" + arxiv)[arXiv:#arxiv]]
  #v(0.3em)
  #body
]

All chapters of this thesis were written under the supervision of ...

#entry(
  [@ch:start: Getting started],
  [*Y. Name*, A. Coauthor and B. Supervisor],
  [Journal Name 1, 100 (2026)],
  doi: "10.0000/example", arxiv: "0000.00000",
)[#me performed the calculations and wrote the text. AC contributed to the analysis. BS supervised the project.]
