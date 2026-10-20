#import "_guide.typ": *

#minitoc-next(true)
= References and back matter <ch:refs>

== Cross-references <sec:refs-cross>

A reference is written `@label` and renders as a link with the kind and number of its target. Numbers are always computed at the target, so a reference to an equation of another chapter, or of an appendix, shows the right number from anywhere.

#example(```typ
@ch:maths, @sec:maths-sums, @eq:maths-schrodinger,
@eq:structure-demo, @app:structure-demo, @fig:floats-demo,
@tab:floats-chains.
```)

The word in front of the number can be replaced for one reference with a supplement in brackets, `@eq:maths-long[Eq.]` giving @eq:maths-long[Eq.], or dropped by referring to the number alone with `#ref(<eq:maths-long>, supplement: none)`.

== Citations and bibliography <sec:refs-cite>

Citations use the same syntax with a key of `references.bib`:

#example(```typ
Factorised scattering @yang-1967-article-deltainteraction and the
reflection equation @sklyanin-1988-article-boundary; see also the
monograph by Baxter @baxter-1982-book-exactlysolved.
```)

The bibliography is printed where `#bibliography(...)` stands in `main.typ`, in the style given there. `template/aps-doi.csl` follows the American Physical Society and adds a DOI link to each entry. Any other Citation Style Language file can be used, or a built-in style such as `"ieee"` or `"nature"`.

== Coauthor contributions <sec:refs-contrib>

Theses built on published papers usually need a page listing each paper and the share of each author. `backmatter/contributions.typ` defines a small command for it, with the journal linked through the DOI and the preprint through its arXiv number:

#code(```typ
#let me = text(weight: "bold")[YN]   // your initials, in bold

#entry(
  [@ch:spins: Spin chains],
  [*Y. Name*, A. Coauthor and B. Supervisor],
  [Physical Review B 100, 000000 (2026)],
  doi: "10.1103/xxxx", arxiv: "2601.00000",
)[#me performed the calculations and wrote the text. ...]
```)

== Title pages and summaries <sec:refs-title>

`frontmatter/titlepage.typ` holds the title page and its reverse (copyright, printer, funding). Universities often supply an official title page that must be used unchanged; place it there. The summaries and acknowledgements in `backmatter/` are ordinary files with an unnumbered heading.
