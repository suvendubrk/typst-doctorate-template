#import "_guide.typ": *

#minitoc-next(true)
= Configuration <ch:config>

All visual settings are arguments of the function `thesis()`. They are collected once, in `meta.typ`, as `conf`, which `main.typ` and `preview.typ` both apply. Change a setting there and every file follows.

#code(```typ
// meta.typ
#let conf = thesis.with(
  title: "Thesis title",
  author: "Your Name",
  font-size: 10pt,
  body-font: "Libertinus Serif",
  math-font: ("KpMath", "New Computer Modern Math"),
  heading-font: ("STIX Two Text", "Libertinus Serif"),
  page-width: 170mm, page-height: 240mm,
  margin: (inside: 24mm, outside: 20mm, top: 24mm, bottom: 22mm),
  theme: "black",
  link-color: rgb("#9F3D1A"),
)

// main.typ
#show: conf
```)

== Fonts and page <sec:config-fonts>

A font argument takes one name or a list of names; the first available one is used. The page size is either a named paper (`paper: "a4"`, `"iso-b5"`, ...) or an explicit trim, which wins when both `page-width` and `page-height` are given. Printers usually specify a trim and margins; copy them here. `inside` is the margin at the binding.

== Colours <sec:config-colours>

The accent colour (chapter kickers, rules, tabs, mini-TOC) comes from a named theme or is given directly. Links (citations, references, URLs) use `link-color`, which defaults to the accent.

#reftable(
  columns: (auto, auto),
  header: ([Theme], [Accent]),
  [`black`], [#box(width: 2.5em, height: 0.8em, fill: themes.black) `#4e4e4e`],
  [`classic`], [#box(width: 2.5em, height: 0.8em, fill: themes.classic) `#1f3a5f`],
  [`modern`], [#box(width: 2.5em, height: 0.8em, fill: themes.modern) `#073929`],
)

New themes are added to the dictionary `themes` in the template (@sec:internals-recipes). With `tab-colors`, each chapter gets its own tab colour; the list is cycled when there are more chapters than colours. The highlight boxes, framed equations and `btable` rules of a chapter follow its tab colour (@ch:floats).

== All options <sec:config-options>

#reftable(
  columns: (auto, 8em, 1fr),
  header: ([Option], [Default], [Meaning]),
  table.cell(colspan: 3)[_Metadata_],
  [`title`, `author`], [`none`], [Written into the PDF properties.],
  [`lang`], [`"en"`], [Language, for hyphenation and quotes.],
  table.cell(colspan: 3)[_Fonts_],
  [`body-font`], [Libertinus Serif], [Running text.],
  [`heading-font`], [Libertinus Serif], [Headings, tabs, running header.],
  [`math-font`], [New Computer Modern Math], [Equations.],
  [`font-size`], [`9.5pt`], [Body text size.],
  table.cell(colspan: 3)[_Page_],
  [`paper`], [`"iso-b5"`], [Named paper size.],
  [`page-width`, `page-height`], [`auto`], [Explicit trim; overrides `paper` when both are set.],
  [`margin`], [inside 26, outside 20, top 24, bottom 22 mm], [Page margins of a two-sided book.],
  table.cell(colspan: 3)[_Colours_],
  [`theme`], [`"classic"`], [Key into `themes`.],
  [`accent`], [`none`], [Explicit accent colour; overrides `theme`.],
  [`part-color`], [`#464737`], [Part rows in the table of contents.],
  [`link-color`], [`auto`], [Citations and references; `auto` is the accent.],
  table.cell(colspan: 3)[_Chapter opener_],
  [`chapter-minitoc`], [`true`], [Automatic "In this chapter" list.],
  [`chapter-raise`], [`-1.1cm`], [Shift of the chapter title towards the page top.],
  table.cell(colspan: 3)[_Side tabs_],
  [`tab-side`], [`"outer"`], [`"outer"`, `"right"` or `"left"`.],
  [`tab-numbering`], [`"1"`], [Label style: `"1"`, `"A"`, `"a"`, `"I"`, `"i"`.],
  [`tab-label-size`], [`9pt`], [Size of the label on the tab.],
  [`tab-active-fill`], [`none`], [Tab colour; `none` uses the accent or `tab-colors`.],
  [`tab-label-color`], [`white`], [Label colour.],
  [`tab-colors`], [`none`], [One colour per chapter, cycled.],
  table.cell(colspan: 3)[_Equations_],
  [`eq-per-chapter`], [`true`], [Number per chapter, (2.4), and per appendix, (2.A.4).],
  [`eq-numbering`], [`"(1.1)"`], [Format: first symbol chapter, second equation.],
  [`eq-numbering-appendix`], [`auto`], [Appendix format; `auto` adds a lettered level.],
  [`eq-break`], [`false`], [`true`: every numbered display may split across pages, number once beside the last line.],
  [`eq-break-height`], [`9cm`], [With `eq-break: false`, numbered displays shorter than this never split.],
  [`eq-num-gap`], [`1em`], [Least space between a formula and its number.],
  table.cell(colspan: 3)[_Inline maths_],
  [`inline-flush`], [`9em`], [Inline formulas up to this width keep the line spacing even.],
  [`inline-reach`], [top 0.32em, bottom 0.38em], [How far they may reach before the line opens up.],
  [`inline-compact`], [`true`], [Delimiters in running text keep text size.],
  table.cell(colspan: 3)[_Figures and tables_],
  [`fig-per-chapter`], [`true`], [Number per chapter, "Figure 2.3".],
  [`fig-numbering`], [`"1.1"`], [Format of figure and table numbers.],
  [`fig-numbering-appendix`], [`auto`], [Appendix format.],
  table.cell(colspan: 3)[_Flip-book_],
  [`flipbook`], [`none`], [A function `n => content` drawn in the page corner (@sec:floats-flipbook).],
  [`flipbook-size`], [`18mm`], [Size of the corner cell.],
  [`flipbook-guide`], [`false`], [Outline the cell on every page.],
)
