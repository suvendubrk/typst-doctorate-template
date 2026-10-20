#import "_guide.typ": *

#minitoc-next(true)
= Getting started <ch:start>

This document is both the manual of the template and an example of its output: every page you read was set by it. Each command is shown as source code in a grey box, followed by the result it produces. The last chapter, @ch:internals, explains how the template is built, so that you can change it.

The template is written for #link("https://typst.app")[Typst], a typesetting system with a markup language close to Markdown and a scripting language for everything else. No package is needed: the whole template is the single file `template/thesis.typ`.

== The files of a thesis

A thesis is split over several files, so that each chapter can be edited and previewed on its own.

#reftable(
  columns: (auto, 1fr),
  header: ([File or folder], [Purpose]),
  [`main.typ`], [The whole thesis. Applies the template once and includes every other file. Render this.],
  [`preview.typ`], [Renders a single file with the full styling, for fast previews of one chapter.],
  [`meta.typ`], [Shared settings and macros. Every chapter imports it, so all files share one configuration (`conf`).],
  [`template/thesis.typ`], [The template itself: layout, numbering, commands.],
  [`template/aps-doi.csl`], [Citation style: American Physical Society, with DOI links.],
  [`frontmatter/`], [Title pages and preface.],
  [`chapters/`], [One file per chapter. The guide chapters and `_guide.typ` can be deleted.],
  [`backmatter/`], [Coauthor contributions, summaries, acknowledgements.],
  [`references.bib`], [The bibliography database (BibTeX format).],
  [`fonts/`], [Optional fonts not built into Typst, such as KpMath and STIX Two.],
)

== Building the thesis

From the folder of the thesis, render the whole document with

#code(```sh
typst compile --font-path fonts --ignore-system-fonts main.typ
typst watch   --font-path fonts --ignore-system-fonts main.typ   # rebuild on save
```)

`--font-path fonts` makes Typst find the fonts in `fonts/`, and `--ignore-system-fonts` guarantees that the result does not depend on what happens to be installed on your computer. The script `build.py` runs the same command from Python. In VS Code, the Tinymist extension previews the thesis live; the settings in `.vscode/` point it at the same fonts.

A long thesis takes several seconds to render. To work on one chapter, render `preview.typ` instead and tell it which file to show:

#code(```sh
typst watch --font-path fonts preview.typ --input file=chapters/ch4_maths.typ
```)

References to other chapters cannot be resolved in such a preview, so they are shown as small yellow labels instead of failing.

== Fonts

The template works with the fonts built into Typst alone. The settings in `meta.typ` prefer two free fonts when they are present in `fonts/`:

- *KpMath* (Kepler) for mathematics, available from #link("https://ctan.org/pkg/kpfonts-otf")[CTAN];
- *STIX Two* for headings and calligraphic letters, available from #link("https://github.com/stipub/stixfonts")[GitHub].

When a font is missing, Typst falls back to the next name in the list and prints a warning. Any other font can be used by changing `body-font`, `heading-font` and `math-font` (@sec:config-fonts).

== Writing a chapter

A chapter is a file that imports `meta.typ` and starts with a level-one heading. `main.typ` includes it inside `#mainmatter[...]`.

#code(```typ
#import "../meta.typ": *

= Spin chains <ch:spins>

In this chapter we study ...

== The Heisenberg model <sec:spins-heisenberg>

$ H = J sum_j bold(S)_j dot bold(S)_(j+1) $ <eq:spins-heisenberg>
```)

Give every chapter, section, equation and figure that you cite a label, written in angle brackets, and refer to it with `@`. Prefixing labels with their kind and chapter (`ch:`, `sec:`, `eq:`, `fig:`, `tab:`, `app:`) keeps them unique across a long thesis.

The source of this guide is a good starting point: each command described here appears in the chapter files exactly as shown.
