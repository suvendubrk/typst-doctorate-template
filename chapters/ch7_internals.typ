#import "_guide.typ": *

#minitoc-next(true)
= How the template works <ch:internals>

This chapter is for readers who want to change the template rather than use it. It assumes the basics of Typst, which are summarised first, and then walks through `template/thesis.typ`.

== Typst in five ideas <sec:internals-typst>

*Set rules* change the default value of an element's property from that point on, within the current scope:

#code(```typ
#set text(size: 10pt)
#set heading(numbering: "1.1")
```)

*Show rules* replace how an element is drawn. The function receives the element (`it`) and returns new content. A show rule can also apply a set rule to one kind of element only:

#code(```typ
#show heading.where(level: 2): it => text(fill: blue, it)
#show figure.caption: set text(size: 0.8em)
```)

*Context* gives access to where content ends up: the page it falls on, the value of a counter there, or the current font size. Everything that depends on the layout is written inside `context { ... }`.

*Counters and states* carry values through the document. `counter(math.equation)` numbers equations; `state("name", initial)` holds any value and is changed with `.update(...)` at a position in the document and read with `.get()` (here) or `.at(location)` (elsewhere).

*Queries* find elements anywhere in the document, `query(heading.where(level: 1))`, and `measure(content)` returns the size content would have. Typst lays the document out several times until such values stop changing.

== The three layers <sec:internals-layers>

#reftable(
  columns: (auto, 1fr),
  header: ([Layer], [Role]),
  [`template/thesis.typ`], [Generic: knows nothing about a particular thesis. Defines `thesis()` and all commands.],
  [`meta.typ`], [Project: imports the template, re-exports it, adds project macros, and fixes the configuration `conf`.],
  [chapters], [Content: import `meta.typ` and nothing else.],
)

Because every file imports `meta.typ`, a macro or setting added there is available everywhere, and `preview.typ` renders a chapter with exactly the styling of the full build.

== A map of thesis.typ <sec:internals-map>

The file is divided into numbered sections:

#reftable(
  columns: (auto, 1fr),
  header: ([Section], [Contents]),
  [§ 0 Shared state], [States through which the commands learn the configuration and the region they are in.],
  [§ 1 Constants and themes], [Ink colours of the table of contents and captions, the indent step, the theme palette. Safe to edit.],
  [§ 2 Layout helpers], [Numbering helpers, the side tabs, the flip-book cell and the running header.],
  [§ 3 Content helpers], [`concept`, `boxeq`, `nonumeq`, `breakeq`, spacing, `subfigure`, `btable`, Dirac notation.],
  [§ 4 Outlines], [Table of contents, list of figures and tables, the mini-TOC.],
  [§ 5 Structure], [`frontmatter`, `mainmatter`, `backmatter`, `part`, `chapter-appendix`.],
  [§ 6 The template], [The function `thesis()`: page set-up, headings, numbering, references, equations.],
)

== Shared state <sec:internals-state>

Commands such as `concept` or `minitoc` are called inside chapters, far from the `thesis()` call that holds the configuration. They read it through states, which `thesis()` sets at the start of the document:

#reftable(
  columns: (auto, 1fr),
  header: ([State], [Meaning]),
  [`_accent`, `_headfont`, `_chapraise`], [Accent colour, heading font and title raise, published by `thesis()`.],
  [`_region`], [`"chapter"` or `"chap-appendix"`: decides whether numbers carry an appendix letter.],
  [`_apphead`, `_ispart`], [True exactly at an appendix heading or a part heading, so the heading rules can tell them from chapters.],
  [`_mtoc`], [The per-chapter mini-TOC override set by `minitoc-next`.],
  [`_pstart`], [Page on which a part divider starts, to uncount its pages.],
  [`_eqbreak`], [`true` inside `breakeq`, `false` inside `nobreakeq`, `auto` elsewhere (the option `eq-break` decides).],
  [`_tabcolors`], [The list `tab-colors`, from which `_chapter-color()` picks the colour of the current chapter for boxes and tables.],
)

Two invisible markers complete the picture: `backmatter()` places one (`<thesis-tabstop>`) where side tabs and the running header must stop, and every part-divider page carries another (`<thesis-divpage>`).

== Numbering <sec:internals-numbering>

Chapter appendices are level-one headings that must not advance the chapter counter, so they carry `numbering: none` and are recognised through `_apphead`. Inside `chapter-appendix`, the section numbering is replaced by a function that inserts the letter.

The show rule for level-one headings (§ 6) resets the counters of equations, figures and tables at every chapter and appendix, and draws the chapter opener. An equation's number is produced by `_eq-num(location, ...)`, which reads the chapter counter, the appendix letter and the equation counter at that location. The same function is used for the tag beside the equation and in the `show ref` rule, which rewrites every reference to an equation, figure, table or appendix from the target's own location. This is why references never disagree with the numbers they point to.

== Equations <sec:internals-equations>

The show rule for numbered displays measures the formula without its number and then decides:

+ The local choice is read first: `breakeq` forces a split, `nobreakeq` keeps the display whole; elsewhere the option `eq-break` decides.
+ A display that may split is drawn without Typst's number, and the number is placed once, beside the last line, whose height is measured from the formula (the last line may sit inside a bracket group spanning several lines).
+ With `eq-break: false`, a display taller than `eq-break-height` is left to Typst, and all others are made unbreakable.
+ If formula and number fit with `eq-num-gap` on both sides, the display is left as Typst draws it; if they fit only with the formula moved left, a grid places them side by side; otherwise the number goes below.

A table has to remain a plain `table` for `figure` to number it as a table, so `btable` cannot read the chapter colour itself, which needs `context`. It draws its rules and tints in placeholder colours instead, and a show rule on `table` in `thesis()` replaces them with shades of the chapter's colour (`_btable-colors`).

Inline formulas are boxed at the height of a capital letter so that they do not change the line spacing (`inline-flush`). Before boxing, the rule measures how far the formula really reaches; only the part beyond `inline-reach` is added back as invisible struts, which open that one line as much as needed.

== Recipes <sec:internals-recipes>

#reftable(
  columns: (auto, 1fr),
  header: ([To change], [Edit]),
  [A theme colour], [Add an entry to `themes` (§ 1) and select it with `theme:`.],
  [Colours of the table of contents or captions], [`_toc-ink`, `_toc-ink-2`, `_toc-ink-3`, `_caption-ink` (§ 1).],
  [Indent of the table of contents], [`_toc-indent` (§ 1).],
  [Size and shape of the side tabs], [The `box(width: 8mm, height: 12mm, ...)` and the spacing in `_side-tabs` (§ 2).],
  [Running header], [`_running-header` (§ 2): what recto and verso pages show.],
  [Chapter opener], [The `is-chapter` branch of the level-one heading rule (§ 6): kicker, title size, rule.],
  [Section headings], [The rules for heading levels 2 to 4 at the start of the heading part of § 6.],
  [Captions], [The `show figure.caption` rules in § 6.],
  [Part pages], [`part()` (§ 5): background tint, sizes, the "PART I" line.],
  [Table rules], [`btable` (§ 3).],
)

Small changes are best made from outside the template, so that it can be updated later. Set and show rules placed in `main.typ` after `#show: conf` override the template for the whole thesis; placed at the top of a chapter, they apply to that chapter only:

#code(```typ
// main.typ, after #show: conf
#show heading.where(level: 2): set text(fill: rgb("#1f3a5f"))
#set par(leading: 0.7em)
#show figure.caption: set text(size: 0.85em)
```)

== Adding your own macros <sec:internals-macros>

Project notation goes into `meta.typ`. A macro is a function; written with math content, it is used inside formulas like any built-in.

#code(```typ
// meta.typ
#let tr = math.op("tr")                      // upright operator: tr A
#let comm(a, b) = $lr([#a, #b])$             // commutator: comm(A, B)
#let dd = math.upright("d")                  // upright differential
```)

A rule that only some chapters need, like `compact-sums` or `flush-sets`, is written as a function of the whole body and applied with `#show: name` at the top of those chapters:

#code(```typ
// meta.typ
#let compact-sums(body) = {
  show math.equation: eq => {
    show sym.sum: it => math.scripts(it)
    show sym.product: it => math.scripts(it)
    eq
  }
  body
}

// in a chapter
#show: compact-sums
```)
