#import "_guide.typ": *

#minitoc-next(true)
= Document structure <ch:structure>

A thesis is a book: it has front matter, a main body divided into parts and chapters, and back matter. This chapter shows how each level is written. Most of these commands change the whole document, so they are shown as source only; their effect is visible in this PDF itself.

== Front, main and back matter <sec:structure-matters>

`main.typ` wraps the thesis in three blocks. Each sets the page numbering and heading style of everything inside it.

#code(```typ
#include "frontmatter/titlepage.typ"

#frontmatter[            // roman folios i, ii, ...; unnumbered headings
  #tableofcontents()
  #include "frontmatter/preface.typ"
]

#mainmatter[             // arabic folios from 1; chapters numbered 1, 2, ...
  #include "chapters/ch1_intro.typ"
]

#backmatter[             // unnumbered headings; side tabs and header stop
  #include "backmatter/summary.typ"
  #bibliography("references.bib", title: "Bibliography",
                style: "template/aps-doi.csl")
]
```)

Inside the front and back matter, write headings as `#heading(numbering: none)[Preface]` or simply `= Preface`; they are unnumbered automatically, still appear in the table of contents, and each gets a side tab of its own. The tabs start at the table of contents, so title pages and dedications have none.

== Parts <sec:structure-parts>

A part divider is a full page with the part number and title, placed on a right-hand page. Its pages are not counted, so the page numbering of the chapters runs on without a gap. The part appears as a centred row in the table of contents.

#code(```typ
#part[Integrable Open Systems]
#part("Time-Dependent Problems", subtitle: "Exact solutions",
      color: rgb("#46543d"), font: "Libertinus Serif")
```)

== Chapters and sections <sec:structure-chapters>

Every level-one heading inside the main matter opens a chapter on a new page, with a "Chapter N" kicker, the title, a dashed rule and a mini table of contents ("In this chapter"). Lower levels are numbered sections:

#code(```typ
= Chapter title <ch:label>          // Chapter 3
== Section <sec:label>              // 3.1
=== Subsection                      // 3.1.1
==== Sub-subsection                 // 3.1.1.1
```)

The mini table of contents is controlled globally by the option `chapter-minitoc` and per chapter by a line placed just before the heading:

#code(```typ
#minitoc-next(false)   // no mini-TOC for the next chapter only
= Introduction
```)

The mini-TOC can also be placed by hand anywhere with `#minitoc()`, for example with a different title: `#minitoc(title: "Overview")`.

== Per-chapter appendices <sec:structure-appendices>

Long derivations can be moved to appendices that belong to a chapter. They are lettered A, B, ... within the chapter, open after the chapter's last page, and number their contents with the letter: sections "2.A.1", equations "(2.A.1)", figures "Figure 2.A.1". The side tab stays on the parent chapter.

#code(```typ
= Some chapter
... text ...
#chapter-appendix("Detailed derivation", id: <app:deriv>)[
  == Preliminaries                  // 2.A.1
  $ R(u) = 1 + u P $ <eq:deriv-r>   // (2.A.1)
]
```)

The `id` makes the appendix citable: `@app:deriv` renders "Appendix 2.A". This chapter ends with such an appendix, @app:structure-demo, which contains @eq:structure-demo.

== Tables of contents <sec:structure-toc>

#code(```typ
#tableofcontents()                         // all levels
#tableofcontents(title: [Contents], depth: 2)
#list-of-figures-and-tables()              // one combined list
```)

The look of the entries is set in the template (@sec:internals-recipes).

== Chapter references <sec:structure-chref>

Typst calls every heading a "Section" in references. `main.typ` therefore contains one line that makes references to chapters read "Chapter N":

#code(```typ
#show heading.where(level: 1): set heading(supplement: [Chapter])
```)

#chapter-appendix("A demonstration appendix", id: <app:structure-demo>)[
  An appendix is written like a chapter. Its equations carry the appendix letter,
  $ T(u) = R_(0 N)(u) dots.c R_(0 1)(u) , $ <eq:structure-demo>
  and @eq:structure-demo can be cited from anywhere in the thesis.

  == A section of the appendix
  Sections inside an appendix are numbered with the letter as well.
]
