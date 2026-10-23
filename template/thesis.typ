// =============================================================================
//  thesis.typ — a self-contained Typst thesis / book template
// =============================================================================
//
//  A two-sided book layout (B5 by default) with:
//    • chapter thumb tabs on the page edge (only the active chapter is shown,
//      optionally one colour per chapter),
//    • a running header (recto: chapter title, verso: current section),
//    • part dividers, front/main/back matter, and per-chapter appendices,
//    • per-chapter equation numbering — "(2.4)" in a chapter, "(2.A.4)" in that
//      chapter's appendix — with cross-references that stay correct from
//      anywhere in the document,
//    • a styled multi-level table of contents + an "In this chapter" mini-TOC,
//    • small extras: a highlight box, boxed / unnumbered equations, subfigures,
//      and an optional flip-book animation in the page corner.
//
//  Inspired by the `bookly` package, re-implemented natively so the template
//  is a single file with no dependencies.
//
// ---------------------------------------------------------------------------
//  QUICK START (a minimal main.typ)
// ---------------------------------------------------------------------------
//
//    #import "template/thesis.typ": *
//    #show: thesis.with(
//      title: "My Thesis",              // PDF metadata (optional)
//      body-font: "STIX Two Text",
//      theme: "classic",                // or accent: rgb("#1f3a5f")
//    )
//
//    #frontmatter[
//      #tableofcontents()
//    ]
//    #mainmatter[
//      #part("The First Part")
//      = A chapter
//      == A section
//      $ E = m c^2 $ <eq:emc>           // numbered (1.1); cite as @eq:emc
//      #chapter-appendix("Extra derivations", id: <app:extra>)[
//        $ R(u) = 1 + u P $             // numbered (1.A.1)
//      ]                                // cite the appendix as @app:extra
//    ]
//    #backmatter[
//      = Conclusions
//    ]
//
// ---------------------------------------------------------------------------
//  WHERE TO CHANGE THINGS
// ---------------------------------------------------------------------------
//
//    Fonts, paper, margins, colours,
//    tabs, equation numbering, …        → arguments of thesis()  (see § 6)
//    TOC / caption ink colours          → constants in § 1
//    Tab geometry (8 mm × 12 mm)        → _side-tabs in § 2
//    Running-header layout              → _running-header in § 2
//    Chapter-opener look                → heading show rule in § 6
//
// ---------------------------------------------------------------------------
//  PUBLIC API (everything not prefixed with "_")
// ---------------------------------------------------------------------------
//
//    thesis(..options, body)            the template — use with #show
//    frontmatter[..]                    roman folios, no heading numbers
//    mainmatter[..]                     arabic folios, "1.1" headings
//    backmatter[..]                     plain pages, tabs stop here
//    part(title, subtitle:, ..)         full-page part divider
//    chapter-appendix(title, id:)[..]   per-chapter appendix (A, B, … per ch.)
//    tableofcontents(title:, depth:)    styled TOC
//    list-of-figures-and-tables(title:) combined list of figures & tables
//    minitoc(title:)                    manual "In this chapter" list
//    minitoc-next(bool)                 per-chapter mini-TOC override
//    concept[..] / highlight-box[..]    tinted box for a key idea
//    boxeq[..]                          boxed display equation
//    nonumeq[..]                        suppress equation numbers inside
//    breakeq[..] / nobreakeq[..]        let a numbered display split across pages, or not
//    subfigure(..)                      (a), (b), … grid under one caption
//    btable(header:, highlight:, ..)    booktabs-style table
//    ket bra bigO                       Dirac brackets / order symbol
//    neg neg2 tightx wide               small horizontal-space helpers
//    themes                             named accent palettes
//
// =============================================================================


// =============================================================================
//  § 0  SHARED STATE — internal; lets helpers read the current configuration
// =============================================================================

#let _accent    = state("thesis-accent", rgb("#1f3a5f"))   // theme accent colour
#let _region    = state("thesis-eq-region", "chapter")     // "chapter" | "chap-appendix"
#let _apphead   = state("thesis-app-head", false)          // true at an appendix heading
#let _ispart    = state("thesis-is-part", false)           // true at a part-divider heading
#let _headfont  = state("thesis-head-font", "Libertinus Serif")
#let _chapraise = state("thesis-chap-raise", -1.1cm)       // chapter-title vertical shift
#let _mtoc      = state("thesis-minitoc-next", auto)       // per-chapter mini-TOC override
#let _pstart    = state("thesis-part-start", 1)            // physical page a divider begins on
#let _eqbreak   = state("thesis-eq-break", auto)           // true in breakeq, false in nobreakeq
#let _tabcolors = state("thesis-tab-colors", none)         // per-chapter tab colours, or none
#let _matter    = state("thesis-matter", none)             // "front" | "main" | "back"
#let _trimguide = state("thesis-trim-guide", false)        // outline the trim when bled

// Marks a front- or back-matter section that gets its own side tab. Placed by
// tableofcontents() and by every unnumbered level-1 heading in those matters.
#let _tabmark(kind) = [#metadata(kind)<thesis-tabpos>]

// Invisible marker emitted by backmatter(): chapter tabs (and the running
// header) stop at the first page carrying it.
#let _tabstop = [#metadata("stop")<thesis-tabstop>]


// =============================================================================
//  § 1  CONFIG CONSTANTS & THEMES — safe to edit
// =============================================================================

// Ink colours of the table of contents (title + entries, per level).
#let _toc-ink   = rgb("#1A1A1A")     // TOC title and level-1 (chapter) entries
#let _toc-ink-2 = rgb("#1A1A1Ad9")   // level-2 entries and appendix rows
#let _toc-ink-3 = rgb("#1A1A1Aa5")   // level-3 and deeper entries
#let _caption-ink = rgb("#222222")   // figure/table caption text

// TOC indent: one fixed step per nesting level (deterministic, unlike the
// built-in `auto`). Everything keys off this single value — the outline's
// per-level indent, the appendix row (shown one step in, at section depth), and
// the extra step that nests an appendix's own sub-headings. Change it here.
#let _toc-indent = 1.7em

// Named accent palettes: pass `theme: "classic"` to thesis(), or override the
// colour entirely with `accent: rgb(..)`. Add your own entries freely.
#let themes = (
  black:   rgb("#4e4e4e"),
  classic: rgb("#1f3a5f"),
  modern:  rgb("#073929"),
)


// =============================================================================
//  § 2  INTERNAL LAYOUT HELPERS — side tabs, flip-book, running header
// =============================================================================

// The "<chapter>.<letter>" label (e.g. "2.A") of the per-chapter appendix at
// `loc`. Reads both counters at that location, so it is correct no matter
// where the call happens. Must be called inside a `context`.
#let _app-num(loc) = numbering("1.A",
  counter(heading).at(loc).first(),
  counter("chap-app").at(loc).first())

// Is location `loc` inside a per-chapter appendix? Used by the TOC, the
// mini-TOC, and equation numbering to letter / nest things correctly. Must be
// called inside a `context`.
#let _in-appendix(loc) = _region.at(loc) == "chap-appendix"

// Format a "chapter.index" number at `loc` — or "chapter.letter.index" if `loc`
// is inside an appendix. This is the SINGLE formatter behind every per-chapter
// number (equations, figures, tables), used for both an element's own tag and
// for @references to it, so the two can never drift apart. Reading each counter
// at `loc` keeps a @ref right no matter where it is cited. `fmt` is the chapter
// format ("(1.1)"), `fmt-app` the appendix format ("(1.A.1)"). Must be called
// inside a `context`.
// The bracket group a formula consists of, or none. ket(), expval() and the
// like return an inline equation whose body is the lr group, so look one level
// in as well.
#let _bracket-of(b) = {
  if b.func() == math.lr { b }
  else if b.func() == math.equation and b.body.func() == math.lr { b.body }
  else { none }
}

// True vertical extent of an inline formula. Typst sizes an inline equation to
// the text edges, so `measure` alone cannot see a deep denominator; laid out as
// a display in inline style, it can. Standing a tall strut of known height on
// the baseline beside it splits that total into ascent and descent. Must be
// called inside a `context`.
#let _inline-extent(body) = {
  let as-display(b) = math.equation(block: true, numbering: none, math.inline(b))
  let total = measure(as-display(body)).height
  let descent = measure(as-display(box(width: 0pt, height: 50pt) + body)).height - 50pt
  (ascent: total - descent, descent: descent)
}

// False when a formula is plainly of ordinary height — letters, digits,
// operators and single-level scripts — so that it can neither reach a
// neighbouring line nor need its delimiters sized. Only formulas that could
// (fractions, roots, accents, bracket groups, big operators, scripts on
// scripts, or anything opaque such as a macro's context) are then measured,
// which keeps the inline-maths rules cheap enough for live preview.
#let _may-reach(c, in-script: false) = {
  if type(c) == array { return c.any(v => _may-reach(v, in-script: in-script)) }
  if type(c) != content { return false }
  let n = repr(c.func())
  if n in ("frac", "binom", "root", "accent", "lr", "underbrace", "overbrace",
           "underbracket", "overbracket", "stretch", "mat", "vec", "cases") { return true }
  if n in ("symbol", "text") { return c.at("text", default: "").contains(regex("[∫∮∬∭∑∏⋃⋂⨁⨂]")) }
  if n in ("space", "h", "primes", "linebreak", "alignpoint") { return false }
  if n == "sequence" { return c.children.any(v => _may-reach(v, in-script: in-script)) }
  if n == "styled" { return _may-reach(c.child, in-script: in-script) }
  if n in ("op", "class", "equation") { return _may-reach(c.at("text", default: c.at("body", default: none)), in-script: in-script) }
  if n == "attach" {
    // a script carrying scripts (e^(k_j^2)) or a tall base climbs out of reach
    if in-script or _may-reach(c.base) { return true }
    return ("t", "b", "tl", "tr", "bl", "br").any(k => _may-reach(c.at(k, default: none), in-script: true))
  }
  true
}

// True if a formula contains a matrix, vector or case block anywhere. Such
// inline formulas are layout (table cells of matrices), not running text, so
// the inline-maths rule in thesis() leaves them at their full height.
#let _has-array(c) = {
  if type(c) == content {
    if c.func() in (math.mat, math.vec, math.cases) { return true }
    for v in c.fields().values() { if _has-array(v) { return true } }
  } else if type(c) == array {
    for v in c { if _has-array(v) { return true } }
  }
  false
}

#let _chap-num(loc, idx, fmt, fmt-app) = {
  let chap = counter(heading).at(loc).first()
  if _in-appendix(loc) {
    numbering(fmt-app, chap, counter("chap-app").at(loc).first(), idx)
  } else {
    numbering(fmt, chap, idx)
  }
}

// Equation number at `loc` (index = the equation counter there).
#let _eq-num(loc, fmt, fmt-app) = _chap-num(loc,
  counter(math.equation).at(loc).first(), fmt, fmt-app)

// Figure/table number at `loc`. Figures count per kind, so the index comes from
// the counter of this figure's own `kind` (image ⇒ "Figure", table ⇒ "Table").
#let _fig-num(el, fmt, fmt-app) = _chap-num(el.location(),
  counter(figure.where(kind: el.kind)).at(el.location()).first(), fmt, fmt-app)

// The sections that own a side tab, in document order: the marked front-
// matter sections (from the table of contents on), the chapters, then the
// marked back-matter sections. Each entry is (kind, location). Needs context.
#let _tab-entries() = {
  let marks = query(<thesis-tabpos>)
  // Front-matter tabs start at the table of contents: sections before it (an
  // abstract, a dedication with a heading) get none.
  let toc = marks.filter(m => m.value == "toc")
  let start = if toc.len() > 0 { toc.first().location().page() } else { 0 }
  let front = marks.filter(m => m.value in ("front", "toc") and m.location().page() >= start)
    .map(m => ("front", m.location()))
  let back  = marks.filter(m => m.value == "back").map(m => ("back", m.location()))
  let chaps = query(heading.where(level: 1)).filter(h => h.numbering != none)
    .map(h => ("chapter", h.location()))
  front + chaps + back
}

// On which page edge does the tab sit here? Returns "right", "left", or none
// (no tab: before the table of contents). `side` is the user setting:
// "outer" follows the recto/verso parity, "left"/"right" pin one edge.
// With main-only, only main-matter pages count (used by the flip-book).
// Must be called inside a `context`.
#let _tab-side-here(side, main-only: false) = {
  let cur = here().page()
  if main-only {
    let chaps = query(heading.where(level: 1)).filter(h => h.numbering != none)
    let stops = query(<thesis-tabstop>)
    if stops.len() > 0 and cur >= stops.first().location().page() { return none }
    if chaps.len() == 0 or chaps.first().location().page() > cur { return none }
  } else {
    let entries = _tab-entries()
    if entries.len() == 0 or entries.first().at(1).page() > cur { return none }
  }
  if side == "left" { "left" }
  else if side == "right" { "right" }
  else { if calc.odd(cur) { "right" } else { "left" } }
}

// The bleed on each edge of the current page, as (left:, right:, top:,
// bottom:). `page.bleed` is one length, or a dictionary that may name the
// inside/outside edges, which swap between recto (odd) and verso pages.
// Must be called inside a `context`.
#let _bleed-here() = {
  let b = page.bleed
  let len(v) = if type(v) == relative { v.length } else { v }
  if type(b) != dictionary { let v = len(b); return (left: v, right: v, top: v, bottom: v) }
  let at(k) = len(b.at(k, default: 0pt))
  let recto = calc.odd(here().page())
  (
    left: if "inside" in b { at(if recto { "inside" } else { "outside" }) } else { at("left") },
    right: if "inside" in b { at(if recto { "outside" } else { "inside" }) } else { at("right") },
    top: at("top"), bottom: at("bottom"),
  )
}

// Vertical thumb index on the page edge (drawn in the page background).
// One block per tab: the front-matter sections (labelled with `front-pattern`),
// the chapters (`pattern`), and the back-matter sections (`back-pattern`). Only
// the ACTIVE tab is filled and labelled; the rest stay invisible, so the stack
// acts as a fixed ruler down the edge. Tabs are 8 mm × 12 mm and shrink when
// there are too many to fit the page. With a print bleed the tabs reach on
// into it, so the trimmed page still shows the full 8 mm.
#let _side-tabs(
  accent: black, font: "Libertinus Serif", side: "outer",
  pattern: "1", front-pattern: "i", back-pattern: "I", size: 9pt,
  active-fill: none, label-color: white,
  colors: none, front-colors: none, back-colors: none,
) = context {
  let tab-side = _tab-side-here(side)
  if tab-side == none { return none }
  let cur = here().page()
  let entries = _tab-entries()
  let n = entries.len()

  let active = 0
  for (i, e) in entries.enumerate() { if e.at(1).page() <= cur { active = i } }
  let on-right = tab-side == "right"
  let bleed = _bleed-here().at(if on-right { "right" } else { "left" })

  // Label and colour of tab i. Without their own lists, front and back tabs
  // continue the cycle of `colors` (or use the accent).
  let nf = entries.filter(e => e.at(0) == "front").len()
  let nc = entries.filter(e => e.at(0) == "chapter").len()
  let cycle(list, k) = if list != none { list.at(calc.rem(k, list.len())) } else { none }
  let info(i) = {
    let kind = entries.at(i).at(0)
    if kind == "front" {
      (numbering(front-pattern, i + 1), if front-colors != none { cycle(front-colors, i) } else { cycle(colors, i) })
    } else if kind == "chapter" {
      (numbering(pattern, i - nf + 1), cycle(colors, i - nf))
    } else {
      (numbering(back-pattern, i - nf - nc + 1), if back-colors != none { cycle(back-colors, i - nf - nc) } else { cycle(colors, i - nf) })
    }
  }
  let (lbl, col) = info(active)
  let fill = if active-fill != none { active-fill } else if col != none { col } else { accent }

  let gap = if n > 12 { 1.5mm } else { 2.5mm }
  let avail = page.height - 44mm
  let h = calc.min(12mm.to-absolute(), (avail.to-absolute() - gap.to-absolute() * (n - 1)) / n)
  let lsize = calc.min(size.to-absolute(), h * 0.6)

  let tabs = range(n).map(i => {
    let on = (i == active)
    box(
      width: 8mm + bleed, height: h,
      inset: if on-right { (right: bleed) } else { (left: bleed) },
      fill: if on { fill } else { none },
      radius: if on { if on-right { (left: 5pt) } else { (right: 5pt) } } else { 0pt },
      if on { align(center + horizon, text(font: font, size: lsize, fill: label-color, weight: "bold")[#lbl]) } else { [] },
    )
  })
  let strip = stack(dir: ttb, spacing: gap, ..tabs)
  if on-right { place(right + horizon, strip) } else { place(left + horizon, strip) }
}

// Flip-book cell (drawn in the page foreground): a small frame in the lower
// corner, only on pages whose chapter tab sits on the RIGHT edge — i.e. the
// natural thumb edge — so nothing appears on left-tab pages or outside the
// main matter. `flipbook` is a user function (page-number) => content.
#let _flipbook(flipbook, size, tab-side, guide) = context {
  if _tab-side-here(tab-side, main-only: true) != "right" { return none }
  let n = here().page()
  let frame = if type(flipbook) == function { flipbook(n) } else { none }
  if frame == none and not guide { return none }
  let cell = box(
    width: size, height: size, clip: true,
    stroke: if guide and frame == none { 0.3pt + luma(75%) } else { none },
    if frame != none { frame } else { none },
  )
  let bleed = _bleed-here()
  place(bottom + right, dx: -5mm - bleed.right, dy: -4mm - bleed.bottom, cell)
}

// Trim guide (drawn in the page foreground): a hairline along the trim, on
// every page, when the page has a bleed and `trim-guide` is on. It sits in the
// foreground so fills and tabs never cover it. A proofing aid only: switch it
// off for the file that goes to the printer.
#let _trim-guide = context {
  let b = _bleed-here()
  if not _trimguide.get() or b.values().all(v => v == 0pt) { return none }
  place(top + left, dx: b.left, dy: b.top,
    rect(width: page.width, height: page.height, stroke: (paint: cmyk(0%, 100%, 0%, 0%), thickness: 0.15pt, dash: "dashed")))
}

// Running header. The folio (page number) sits at the OUTER corner. A recto
// (odd) page carries the chapter/appendix title, a verso (even) page the most
// recent section — or, inside an appendix, the appendix's own title. A
// hairline rule fills the gap toward the spine. Shown on main-matter pages
// except each CHAPTER's opening page (appendix openers keep it, so a one-page
// appendix still shows its title); everywhere else only the folio prints.
#let _running-header(font, margin) = context {
  let cur = here().page()
  let odd = calc.odd(cur)
  let pageno = counter(page).display()   // current page number, current format

  // Top-level entries = numbered chapters AND per-chapter appendices (which
  // carry numbering: none, hence the _apphead check); parts are excluded.
  let chaps = query(heading.where(level: 1)).filter(h =>
    not _ispart.at(h.location()) and (h.numbering != none or _apphead.at(h.location())))
  let stops = query(<thesis-tabstop>)
  let in-back = stops.len() > 0 and cur >= stops.first().location().page()
  let on-opener = chaps.any(h => (not _apphead.at(h.location())) and h.location().page() == cur)
  let active = none
  for h in chaps { if h.location().page() <= cur { active = h } }
  let is-content = (chaps.len() > 0) and (not in-back) and (not on-opener) and (active != none)

  set text(font: font, size: 9pt)
  set par(justify: false, first-line-indent: 0pt)
  let rule = box(width: 1fr, height: 0.5pt, fill: black)   // hairline on the baseline

  if not is-content {
    // openers / front / back matter: folio at the outer corner only
    block(width: 100%, if odd { align(right, pageno) } else { align(left, pageno) })
  } else if odd {
    // recto:  [———— rule] Chapter / Appendix Title   <folio>
    block(width: 100%, { rule; h(0.6em); active.body; h(0.9em); pageno })
  } else {
    // verso:  <folio> Section Title [rule ————]
    let sec-title = if _apphead.at(active.location()) {
      active.body                       // inside an appendix: its own title
    } else {
      let sec = none
      for h in query(heading) {
        if (h.level >= 2 and h.numbering != none
            and h.location().page() <= cur
            and h.location().page() >= active.location().page()) { sec = h }
      }
      if sec != none { sec.body } else { none }
    }
    block(width: 100%, {
      pageno
      if sec-title != none { h(0.9em); sec-title; h(0.6em) } else { h(0.6em) }
      rule
    })
  }
}


// =============================================================================
//  § 3  CONTENT HELPERS — boxes, equations, subfigures, spacing
// =============================================================================

// The tab colour of the chapter at the current position (the n-th numbered
// chapter takes the n-th entry of `tab-colors`, cycling), or the accent when
// no tab colours are set or outside the chapters. Must be called in a context.
#let _chapter-color() = {
  let cols = _tabcolors.get()
  let n = query(selector(heading.where(level: 1)).before(here()))
    .filter(h => h.numbering != none).len()
  if cols == none or n == 0 { _accent.get() } else { cols.at(calc.rem(n - 1, cols.len())) }
}

// A single understated tinted box to flag a key idea (a thesis, not a
// textbook). Title is optional; the colour defaults to the chapter's tab
// colour (or the theme accent): a light tint for the fill, the colour itself
// for the bar.
//   #concept[Energy is conserved.]
//   #concept(title: "Main result")[ ... ]
#let concept(body, title: none, color: none) = context {
  let c = if color != none { color } else { _chapter-color() }
  let ins = 12pt
  block(
    width: 100%, breakable: true, above: 0.9em, below: 0.9em,
    fill: c.lighten(92%), inset: (x: ins, y: 9pt),
    stroke: (left: 2pt + c),
  )[
    #if title != none { text(weight: "bold", fill: c.darken(8%), size: 0.95em)[#title]; linebreak() }
    #set text(size: 0.97em)
    // Display equations span the FULL text width despite the box inset, so
    // their numbers line up with equation numbers outside the box.
    #show math.equation.where(block: true): it => pad(x: -ins, it)
    #body
  ]
}
#let highlight-box = concept   // alias

// A display equation inside a rounded, accent-tinted frame:
//   #boxeq[$ x = y $]
#let boxeq(body) = context {
  let c = _chapter-color()
  align(center, box(stroke: 0.8pt + c.transparentize(60%), radius: 4pt, inset: (x: 10pt, y: 8pt), fill: c.lighten(95%), body))
}

// Suppress equation numbers for everything inside:
//   #nonumeq[$ a = b $]
#let nonumeq(body) = { set math.equation(numbering: none); body }

// Let a numbered display split across pages at its line breaks, whatever its
// height. The number is set once, beside the last line. With the global
// option `eq-break: true` every numbered display behaves like this, and
// nobreakeq keeps a single one whole instead.
//   #breakeq[$ a &= b \ &= c $ <eq:label>]
//   #nobreakeq[$ a &= b \ &= c $]
#let breakeq(body) = { _eqbreak.update(true); body; _eqbreak.update(auto) }
#let nobreakeq(body) = { _eqbreak.update(false); body; _eqbreak.update(auto) }

// Small horizontal-space helpers for fine-tuning maths (widths in em match
// the TeX \!, \negmedspace, and \; conventions).
#let neg    = h(-0.1667em)
#let neg2   = h(-0.3334em)
#let tightx = h(-0.08em)
#let wide   = h(0.6em)

// A grid of sub-images labelled (a), (b), … sharing ONE caption/number:
//   #subfigure(image("a.png"), image("b.png"), caption: [Two views.])
// The group is a single figure — the sub-items cannot be referenced
// individually.
#let subfigure(..items, columns: (1fr, 1fr), caption: none, gap: 1em) = figure(
  grid(columns: columns, column-gutter: gap, row-gutter: 0.6em,
    ..items.pos().enumerate().map(((i, it)) => block(width: 100%)[
      #align(center, it)
      #align(center, text(weight: "bold")[(#numbering("a", i + 1))])
    ])),
  caption: caption,
)

// Booktabs-style table: no vertical rules; a heavy rule top and bottom and a
// light rule under the header. Handy default for scientific tables.
//   header:    a tuple of header cells, e.g. ([$(m,n)$], [term], [verdict])
//   highlight: 1-based body-row indices to tint softly (1 = first data row)
//   inset:     cell padding; narrow it for a wide table instead of letting cells wrap
//   ..rows:    the body cells, row-major (like the built-in `table`)
// The rules and the row tint follow the chapter's tab colour. A table must stay
// a plain `table` for figure() to number it as a Table, so it cannot read the
// colour itself (that needs `context`); it is drawn with placeholder colours
// that a show rule in thesis() swaps for the chapter's (see _btable-colors).
#let _bt-tint  = rgb("#010203")   // placeholder: highlighted-row fill
#let _bt-heavy = rgb("#010204")   // placeholder: top and bottom rules
#let _bt-light = rgb("#010205")   // placeholder: rule under the header
#let btable(columns: 3, align: center + horizon, inset: (x: 12pt, y: 7pt), header: (), highlight: (), ..rows) = table(
  columns: columns,
  align: align,
  inset: inset,
  stroke: none,
  fill: (x, y) => if highlight.contains(y) { _bt-tint } else { none },
  table.hline(stroke: 0.7pt + _bt-heavy),
  table.header(..header),
  table.hline(stroke: 0.4pt + _bt-light),
  ..rows,
  table.hline(stroke: 0.7pt + _bt-heavy),
)

// Replace the placeholder colours of a btable with shades of `c`. Tables
// without placeholders are returned unchanged.
#let _btable-colors(it, c) = {
  let swap(paint) = if paint == _bt-tint { c.lighten(88%) }
    else if paint == _bt-heavy { c.darken(25%) }
    else if paint == _bt-light { c.lighten(30%) }
    else { paint }
  let kids = it.children.map(k => {
    if k.func() == table.hline and type(k.stroke) == stroke and k.stroke.paint in (_bt-heavy, _bt-light) {
      table.hline(stroke: k.stroke.thickness + swap(k.stroke.paint))
    } else { k }
  })
  let marked = kids != it.children
  if not marked { return it }
  let f = it.fields()
  let _ = f.remove("children")
  let old = f.at("fill", default: none)
  if type(old) == function { f.fill = (x, y) => { let v = old(x, y); if v == none { none } else { swap(v) } } }
  table(..f, ..kids)
}

// Common maths notation (physics). ket/bra render Dirac brackets; bigO is an
// upright order symbol that never collides with an italic variable O.
//
// The math font draws its smallest bar | shorter than its smallest angle
// (0.89 em against 0.97 em); every larger size of the two matches. A ket of
// ordinary height asks for a delimiter between those two heights, so lr()
// would hand the bar its next size up while the angle keeps its first — a bar
// visibly taller than its bracket and hanging below the baseline. Below that
// threshold both delimiters are therefore pinned to their first size; taller
// contents stretch freely, where the sizes agree again.
#let _dirac(body) = if not _may-reach(body) { math.lr(body, size: 0.9em) } else { context {
  // (measured as a display: an inline formula reports only the text height)
  let h = measure(math.equation(block: true, numbering: none, $lr(chevron.l #body chevron.r)$)).height
  if h <= 1.02em.to-absolute() { math.lr(body, size: 0.9em) } else { math.lr(body) }
} }
#let ket(x) = _dirac($| #x chevron.r$.body)
#let bra(x) = _dirac($chevron.l #x |$.body)
#let bigO(x) = $upright(O)(#x)$

// Closed brackets. One macro covers all three shapes an angle bracket takes,
// so an overlap, a matrix element and an average are never spelled three
// different ways in the same chapter:
//   braket(a, b)            ⟨a|b⟩      overlap
//   braket(a, hat(O), b)    ⟨a|O|b⟩    matrix element
//   expval(hat(O))          ⟨O⟩        average  (an alias, for reading the source)
// The dividing bars are grown with the angles, so ⟨, | and ⟩ are all the same
// height — mid() is what carries the scaling. Bare mid() is a relation, and
// would open a thick space on either side; re-declaring it an ordinary symbol
// keeps the bracket snug while leaving the bar full length. Write an average as
// expval(..) rather than the one-argument braket(..) — same output, but the
// intent is legible in the source.
#let braket(..parts) = {
  let items = parts.pos()
  _dirac($chevron.l #items.join(math.class("normal", $mid(|)$)) chevron.r$.body)
}
#let expval(x) = $lr(chevron.l #x chevron.r)$

// Vectorised (superoperator) states: a density matrix reshaped into a vector
// carries a doubled bracket, |ρ⟩⟩, to distinguish it from a state of the
// original Hilbert space.
#let dket(x) = _dirac($| #x chevron.r chevron.r$.body)
#let dbra(x) = _dirac($chevron.l chevron.l #x |$.body)


// =============================================================================
//  § 4  OUTLINES — table of contents, list of figures/tables, mini-TOC
// =============================================================================

// Table of contents: a centred title (styled like the other front-matter
// headings) followed by the entries. `depth: none` lists every level.
#let tableofcontents(title: [Contents], depth: none) = {
  pagebreak(weak: true)
  context if _matter.get() == "front" { _tabmark("toc") } else if _matter.get() == "back" { _tabmark("back") }
  context {
    v(_chapraise.get())
    block(below: 0.9cm, width: 100%)[
      #set par(justify: false, first-line-indent: 0pt)
      #align(center, text(font: _headfont.get(), size: 16pt, fill: _toc-ink, weight: "medium")[#title])
    ]
    v(0.5cm)
  }
  outline(title: none, indent: _toc-indent, depth: depth)
}

// TOC row for a section-or-deeper entry (levels 2, 3, 4). A per-chapter
// appendix is a level-1 heading shown at SECTION depth, so its own sub-headings
// (level 2, 3, …) must drop one extra step to nest beneath it rather than
// colliding with it. Detect them via the equation region state and pad.
#let _toc-sub(it, ink) = context {
  let row = text(size: 10.5pt, fill: ink, it)
  if it.element != none and _in-appendix(it.element.location()) {
    pad(left: _toc-indent, row)
  } else { row }
}

// Figures and tables in one combined list.
#let list-of-figures-and-tables(title: [Figures and Tables]) = {
  pagebreak(weak: true)
  context {
    set align(center)
    heading(numbering: none, outlined: true)[#title]
    v(0.5cm)
    outline(title: none, target: figure)
  }
}

// "In this chapter": lists the sections (and the per-chapter appendices) of
// the chapter the call sits in. Inserted automatically on every chapter
// opener when thesis(chapter-minitoc: true); call it manually anywhere
// otherwise. Unnumbered headings are skipped.
#let minitoc(title: "In this chapter") = context {
  let acc = _accent.get()
  let pg = here().page()
  let hs = query(heading)

  // The chapter this mini-TOC belongs to: the last level-1 heading on or
  // before this page.
  let idx = none
  for (i, h) in hs.enumerate() {
    if h.level == 1 and h.location().page() <= pg { idx = i }
  }
  if idx == none { return none }

  // Collect the chapter's sub-headings AND its per-chapter appendices (which
  // are level-1 headings flagged by _apphead); stop at the next real chapter.
  // Unnumbered sub-headings are skipped — they have no label to print.
  let subs = ()
  let j = idx + 1
  while j < hs.len() and (hs.at(j).level > 1 or _apphead.at(hs.at(j).location())) {
    let s = hs.at(j)
    if s.numbering != none or _apphead.at(s.location()) { subs.push(s) }
    j += 1
  }
  if subs.len() == 0 { return none }

  block(above: 0.4em, below: 1.1em, inset: (left: 2pt))[
    #text(size: 8.5pt, weight: "semibold", fill: acc, tracking: 1pt)[#upper(title)]
    #v(0.3em)
    #set text(size: 9.5pt, weight: "regular")
    #set par(spacing: 0.25em)
    #set block(spacing: 0.25em)
    #{
      // Displayed label + list level of a sub-entry. The appendix heading
      // (numbering: none, so its "<chapter>.<letter>" label is built by hand)
      // lists at section level; the appendix's own sub-headings drop one level
      // deeper to nest beneath it, exactly as in the main table of contents.
      let info(s) = if _apphead.at(s.location()) {
        (num: _app-num(s.location()), lvl: 2)
      } else {
        let deeper = if _in-appendix(s.location()) { 1 } else { 0 }
        (num: numbering(s.numbering, ..counter(heading).at(s.location())), lvl: s.level + deeper)
      }
      // Widest label per level → a fixed label column, so every title starts
      // at the same x whether the label is "2.3" or the lettered "2.A" (whose
      // "A" is wider than a digit).
      let colw = (:)
      for s in subs {
        let i = info(s)
        let w = measure(text(size: 9.5pt, weight: if i.lvl == 2 { "semibold" } else { "regular" })[#i.num]).width
        colw.insert(str(i.lvl), calc.max(colw.at(str(i.lvl), default: 0pt), w))
      }
      for s in subs {
        let i = info(s)
        let p = counter(page).at(s.location()).first()
        block(above: 0pt, below: 0.4em)[
          #h((i.lvl - 2) * 1.2em)#box(width: colw.at(str(i.lvl)) + 0.5em)[#text(fill: acc, weight: if i.lvl == 2 { "semibold" } else { "regular" })[#i.num]]#s.body#box(width: 1fr, inset: (x: 4pt), repeat[.])#p
        ]
      }
    }
  ]
}

// Per-chapter override for the automatic mini-TOC. Put it on its own line
// just BEFORE a chapter heading: #minitoc-next(false) hides the list for that
// chapter only, #minitoc-next(true) forces it on. Otherwise the global
// `chapter-minitoc` setting applies.
#let minitoc-next(show-it) = _mtoc.update(show-it)


// =============================================================================
//  § 5  DOCUMENT STRUCTURE — matters, part dividers, per-chapter appendices
// =============================================================================

// Front matter: roman folios (i, ii, …) centred at the bottom, headings
// unnumbered. Put the title page, TOC, preface, … inside.
#let frontmatter(body) = {
  set page(numbering: "i", number-align: bottom + center, header: none)
  counter(page).update(1)
  set heading(numbering: none)
  _matter.update("front")
  body
}

// Main matter: arabic folios restarting at 1, "1.1"-numbered headings.
// Every `= Heading` inside starts a chapter.
#let mainmatter(body) = {
  set page(numbering: "1"); counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "1.1")
  _matter.update("main")
  body
}

// Back matter: plain pages (folio centred at the bottom), unnumbered
// headings; chapter tabs and the running header stop here.
#let backmatter(body) = {
  set page(numbering: "1", number-align: bottom + center, header: none)
  set heading(numbering: none)
  _tabstop
  _matter.update("back")
  body
}

// Full-page part divider: tinted page, "PART I" + title (+ subtitle) centred.
// The divider page and its pagebreak blanks are UNCOUNTED — the next chapter
// resumes the page numbering with no gap — and the part appears as a centred
// row in the TOC.
#let part(title, subtitle: none, color: rgb("#795c4d"), font: "Libertinus Serif") = {
  // Remember the PHYSICAL page this divider starts on, to count exactly the
  // pages it consumes (below). Physical pages are unaffected by the counter(page)
  // adjustments parts make, so this is stable across layout passes.
  context { _pstart.update(here().page()) }
  set page(
    numbering: none, header: none, foreground: _trim-guide, fill: rgb("#d5c1b765"),
    // An invisible marker on every page the divider occupies. Forced blank
    // leaves inherit the page settings, so they carry it too — letting us count
    // the divider's real page span instead of guessing it from page parity.
    background: [#metadata(none)<thesis-divpage>],
  )
  pagebreak(to: "odd", weak: true)
  counter("part").step()
  set par(justify: false)
  // The heading exists only so the part shows up in the TOC; the level-1 show
  // rule skips rendering it (via _ispart) and this block draws the page.
  _ispart.update(true)
  heading(level: 1, numbering: none, outlined: true)[#title]
  _ispart.update(false)
  v(1fr)
  set align(center)
  context text(font: font, size: 14pt, fill: color, tracking: 2pt)[PART #counter("part").display("I")]
  v(0.6cm)
  text(font: font, size: 30pt, weight: "medium", fill: color)[#title]
  if subtitle != none {
    v(0.4cm)
    text(font: font, size: 14pt, style: "italic", fill: color.lighten(20%))[#subtitle]
  }
  v(2fr)
  pagebreak(to: "odd", weak: true)                 // next chapter on a recto
  // Un-count exactly the pages this divider produced, so numbering resumes
  // seamlessly. `drop` = the divider markers between where the part began and
  // here (physical pages) — no parity assumption, no self-referential counter.
  context {
    let p0 = _pstart.get()
    let drop = query(<thesis-divpage>)
      .filter(m => p0 <= m.location().page() and m.location().page() < here().page())
      .len()
    counter(page).update(n => calc.max(n - drop, 0))
  }
}

// Per-chapter appendix. Place after a chapter's content (before the next
// chapter). Renders a chapter-style heading "Appendix <chapter>.<letter> •
// Title", lettered A, B, … within each chapter. Equations inside it number
// "(<chapter>.<letter>.<n>)" and sub-headings "<chapter>.<letter>.<n>" (write
// them with == ; a further === nests as "<chapter>.<letter>.<n>.<m>"). It
// does NOT advance the chapter counter, and the side tab stays on the parent
// chapter.
//
//   = Some chapter
//   ... chapter text ...
//   #chapter-appendix("Detailed derivation", id: <app:deriv>)[
//     == Preliminaries        // numbered 3.A.1
//     ...
//   ]
//   ... as shown in @app:deriv ...     // renders "Appendix 3.A", clickable
//
// `id:` (a label like <app:x>, or a string) makes the appendix referenceable.
#let chapter-appendix(title, body, id: none) = {
  counter("chap-app").step()
  _apphead.update(true)
  // Attach the label to the HEADING itself (not the surrounding block) so
  // that @id resolves to a referenceable heading.
  [#heading(level: 1, numbering: none, outlined: true)[#title]#if id != none {
     if type(id) == label { id } else { label(id) }
   }]
  _apphead.update(false)
  _region.update("chap-appendix")
  context {
    // Sub-headings inside the appendix: restart the section counter and
    // display "<chapter>.<letter>.<n>". The appendix letter is captured HERE
    // as a plain value, so the numbering closure needs no context of its own
    // — the TOC, the mini-TOC, and @references therefore all render the right
    // letter no matter where they sit. Zero components are dropped so a bare
    // `===` (with no preceding `==`) still reads "<chapter>.<letter>.1".
    //
    // The section counter is zeroed with a RELATIVE update (prev => …) that
    // keeps the chapter component. Do NOT reset it via `counter(heading).get()`
    // → `.update(...)`: reading a counter to write the same counter fails to
    // converge across layout passes. There is no restore afterwards — an
    // appendix is the last thing in its chapter, and the next chapter's level-1
    // heading re-steps the counter regardless.
    let letter = counter("chap-app").get().first()
    // (..prev) because an update function receives the counter's numbers as
    // separate arguments — a mid-chapter counter like (2, 5) passes two.
    counter(heading).update((..prev) => (prev.pos().first(), 0))
    set heading(numbering: (..n) => {
      let v = n.pos()
      numbering("1.A.1", v.first(), letter, ..v.slice(1).filter(x => x != 0))
    })
    body
  }
  _region.update("chapter")
}


// =============================================================================
//  § 6  THE TEMPLATE — apply with:  #show: thesis.with(..options)
// =============================================================================

#let thesis(
  // ---- PDF metadata (optional) ----
  title: none,                // document title written into the PDF
  author: none,               // a name, or an array of names
  // ---- Fonts (an array means fallbacks) ----
  body-font: "Libertinus Serif",
  heading-font: "Libertinus Serif",
  math-font: "New Computer Modern Math",
  font-size: 9.5pt,
  lang: "en",
  // ---- Page ----
  paper: "iso-b5",            // any Typst paper name ("a4", "jis-b5", …)
  page-width: auto,           // set both to override `paper` with a custom trim
  page-height: auto,          // (printers usually specify a trim, not a name)
  margin: (inside: 26mm, outside: 20mm, top: 24mm, bottom: 22mm),
  bleed: 0mm,                 // print bleed beyond the trim, e.g. 2mm; 0mm =
                              //  none. A length bleeds the outside, top and
                              //  bottom edges only, never the spine; a
                              //  dictionary sets the edges itself, e.g.
                              //  (rest: 2mm) for all four. The PDF page grows
                              //  by it and gets a TrimBox; page fills and the
                              //  side tabs run on into it. Size and margins
                              //  stay the trim's
  trim-guide: false,          // with a bleed: outline the trim on every page
                              //  (proofing only — off for the printer's file)
  // ---- Colours ----
  theme: "classic",           // key into `themes` (§ 1)
  accent: none,               // explicit accent colour; overrides `theme`
  part-color: rgb("#464737"), // "Part I" rows in the TOC (the divider page
                              //  colour is part()'s own `color:` argument)
  link-color: auto,           // citations & cross-references; auto → accent,
                              //  or any colour (black ≈ disable)
  // ---- Chapter opener ----
  chapter-minitoc: true,      // auto "In this chapter" list on chapter openers
  chapter-raise: -1.1cm,      // shift of the opener title toward the page top
                              //  (more negative = higher)
  // ---- Side tabs ----
  tab-side: "outer",          // "outer" | "right" | "left"
  tab-numbering: "1",         // label style: "1" | "A" | "a" | "I" | "i"
  tab-label-size: 9pt,        // label size on the active tab
  tab-active-fill: none,      // active-tab colour; none → accent / tab-colors
  tab-label-color: white,     // label colour on the active tab
  tab-colors: none,           // optional array: one base colour per chapter
                              //  (cycles when shorter than the chapter count)
  tab-numbering-front: "i",   // labels of the front-matter tabs (from the TOC on)
  tab-numbering-back: "I",    // labels of the back-matter tabs
  tab-colors-front: none,     // colours of the front-matter tabs; none = continue
  tab-colors-back: none,      //  the tab-colors cycle. Same for the back matter
  // ---- Flip-book (optional page-corner animation) ----
  flipbook: none,             // (page-number) => frame content; none = off
  flipbook-size: 18mm,
  flipbook-guide: false,      // outline the cell even on frameless pages
  // ---- Equation numbering ----
  eq-per-chapter: true,       // "(2.4)" per chapter / "(2.A.4)" in appendices;
                              //  false = Typst's global numbering
  eq-numbering: "(1.1)",      // format string: first symbol = chapter, second
                              //  = equation. E.g. "1.1", "[1.1]", "(1.1)"
  eq-numbering-appendix: auto, // appendix format "(<ch>.<letter>.<eq>)"; auto =
                              //  eq-numbering with a lettered middle level
  eq-break: false,            // true: every numbered display may split across
                              //  pages at its line breaks, its number set once
                              //  beside the last line (as inside breakeq)
  eq-break-height: 9cm,       // with eq-break: false, numbered displays shorter
                              //  than this never split
                              //  across pages (Typst would repeat the number on
                              //  both pieces); none = all may split
  eq-num-gap: 1em,            // least space between a formula and its number;
                              //  a wider formula shifts left, then the number
                              //  drops below it
  // ---- Inline maths ----
  inline-flush: 9em,          // inline formulas up to this width are boxed at
                              //  capital height, so subscripts, kets and
                              //  fractions never open up their line; wider ones
                              //  keep breaking at their relations. none = off
  inline-reach: (top: 0.32em, bottom: 0.38em),
                              // how far a boxed formula may reach above the
                              //  capitals / below the baseline before its line
                              //  opens up. Keep top + bottom under the leading
                              //  (0.72em) so neighbouring lines never touch
  inline-compact: true,       // delimiters in running-text maths stay at text
                              //  size instead of stretching around their content,
                              //  and scripts on them sit as on a plain letter
  // ---- Figure & table numbering ----
  fig-per-chapter: true,      // "Figure 2.3" / "Table 2.3" per chapter; false =
                              //  Typst's global "Figure 1, 2, 3"
  fig-numbering: "1.1",       // format: first symbol = chapter, second = index
  fig-numbering-appendix: auto, // appendix format "<ch>.<letter>.<index>"; auto
                              //  = fig-numbering with a lettered middle level
  body,
) = {
  let accent = if accent != none { accent } else { themes.at(theme, default: themes.classic) }
  let lc = if link-color == auto { accent } else { link-color }
  // Appendix formats: explicit, or derived by lettering a middle level
  // ("(1.1)" → "(1.A.1)", "1.1" → "1.A.1").
  let eq-numbering-app = if eq-numbering-appendix != auto { eq-numbering-appendix } else { eq-numbering.replace("1.1", "1.A.1") }
  let fig-numbering-app = if fig-numbering-appendix != auto { fig-numbering-appendix } else { fig-numbering.replace("1.1", "1.A.1") }

  // ---- Document-wide basics -------------------------------------------------
  set document(
    ..(if title != none { (title: title) } else { (:) }),
    ..(if author != none { (author: author) } else { (:) }),
  )
  set text(font: body-font, size: font-size, lang: lang)
  show math.equation: set text(font: math-font)
  // Let multi-line display equations break across pages (at their line
  // breaks) instead of being pushed to the next page as a whole.
  show math.equation: set block(breakable: true)
  // ...except numbered ones of ordinary height: Typst repeats the number on
  // every page a numbered display is split over, so those move whole to the
  // next page, as in LaTeX. Only a display taller than `eq-break-height` may
  // still split, since keeping it whole would empty most of a page.
  //
  // The same rule keeps an equation number clear of its formula. Typst centres
  // the formula and pins the number to the right edge whatever the width, so a
  // wide formula runs into its number. As in LaTeX, a formula that would come
  // within `eq-num-gap` of the number is first moved left, and if even that
  // does not leave room, the number drops to a line of its own below it.
  show math.equation.where(block: true): it => context {
    if it.numbering == none { return it }
    let bare = math.equation(block: true, numbering: none, it.body)
    let size = measure(bare)
    // Local choice (breakeq / nobreakeq) first, else the global eq-break.
    let mode = _eqbreak.get()
    let force-break = if mode == auto { eq-break } else { mode }
    if mode == auto and not force-break and eq-break-height != none and size.height >= eq-break-height.to-absolute() { return it }
    set block(breakable: false) if not force-break and (eq-break-height != none or mode == false)
    let num = if eq-per-chapter { _eq-num(here(), eq-numbering, eq-numbering-app) }
              else { numbering(it.numbering, ..counter(math.equation).get()) }
    let w = size.width
    let nw = measure(num).width
    let gap = eq-num-gap.to-absolute()
    let width = page.width - margin.at("inside", default: margin.at("left", default: 0pt)) - margin.at("outside", default: margin.at("right", default: 0pt))
    if force-break {
      // breakeq: the formula splits freely and the number is drawn only once,
      // beside its last line (Typst would repeat it on every page).
      // The last line is whatever follows the final line break, which may sit
      // inside a bracket group spanning several lines.
      let has-break(c) = type(c) == content and (c.func() == linebreak
        or c.fields().values().any(v => if type(v) == array { v.any(has-break) } else { has-break(v) }))
      let tail(c) = {
        let b = if c.func() == math.lr { c.body } else { c }
        if b.func() != [].func() { return c }
        let kids = b.children
        let out = ()
        for k in kids.rev() {
          if k.func() == linebreak { break }
          if has-break(k) { out.insert(0, tail(k)); break }
          out.insert(0, k)
        }
        out.join()
      }
      let lh = measure(math.equation(block: true, numbering: none, tail(it.body))).height
      return block(width: 100%, breakable: true, {
        set block(spacing: 0pt)
        if w + 2 * (nw + gap) <= width {
          bare; v(-lh); block(width: 100%, height: lh, align(right + horizon, num))
        } else if w + nw + gap <= width {
          pad(right: nw + gap, bare); v(-lh); block(width: 100%, height: lh, align(right + horizon, num))
        } else {
          bare; v(0.2em); align(right, num)
        }
      })
    }
    if w + 2 * (nw + gap) <= width { it }
    else if w + nw + gap <= width {
      block(width: 100%, breakable: false,
        grid(columns: (1fr, nw), column-gutter: gap, align: (center + horizon, right + horizon), bare, num))
    } else {
      block(width: 100%, breakable: false, { bare; v(0.2em, weak: false); align(right, num) })
    }
  }
  // Normal-ordering colons ": A :" hug their content: the math colon defaults
  // to relation-class spacing, which reads far too loose for ordered products.
  // Reclassifying it as an ordinary atom removes that spacing, so bare colons
  // in equations need no wrapper command. Scoped to equations only — prose
  // colons must stay plain text or they break lines on their own.
  show math.equation: eq => {
    show sym.colon: it => math.class("normal", it)
    eq
  }
  // Running-text maths stays on the line grid of the text. A ket, a stacked
  // fraction or a subscript would otherwise push its line away from the next,
  // so a paragraph full of notation loses its even spacing. Each inline formula
  // is boxed at the height of a capital (it still draws in full, into the
  // leading), and its delimiters keep their text size, as in LaTeX. A box cannot
  // break across lines, so formulas wider than `inline-flush` are left free to
  // break at their relations. Display equations mark themselves with a style
  // that is invisible inside them (no hyphenation) so that inline pieces nested
  // in a display, such as a measured sub-formula, keep their real size.
  show math.equation.where(block: true): set text(hyphenate: false)
  show math.equation.where(block: false): it => context {
    if text.hyphenate == false { it } else {
      // 0.9em rather than 1em: the bar's first size is 0.89 em, so at 1em
      // every |x| and |ψ⟩ would take the next, visibly oversized bar.
      set math.lr(size: 0.9em) if inline-compact
      // A script on a bracket group, ⟨…⟩_mf or ⟨…⟩^(1), is placed by Typst
      // against the whole group, so a subscript inside it drags the outer one
      // down. Attaching it after the bracket instead puts it where LaTeX would.
      // A group given an explicit size, lr(size: #100%, (…))^n, is meant to
      // enclose its content in full, so it keeps the script on itself.
      show math.attach: a => if inline-compact and _bracket-of(a.base) != none and not _bracket-of(a.base).has("size") {
        let f = a.fields()
        let _ = f.remove("base")
        a.base + math.attach(sym.zws, ..f)
      } else { a }
      // Matrices and the like are layout, not running text (a table of them
      // would collapse), and very wide formulas must stay breakable.
      // (The inner context makes `measure` see the two rules just above; the
      // outer one only knows the styles from before them.)
      if inline-flush == none or _has-array(it.body) { it } else { context {
        // The box keeps ordinary notation on the grid, but a formula that
        // reaches far above the capitals or below the baseline (a fraction
        // with scripted denominator, a double accent) would draw into the
        // neighbouring line. Measure its true extent and, for only the part
        // beyond what the leading can absorb, add invisible struts so that this
        // one line opens up, as LaTeX's \lineskip does.
        let cap = measure([X]).height
        let ext = if _may-reach(it.body) { _inline-extent(it.body) } else { (ascent: cap, descent: 0pt) }
        let up = ext.ascent - cap - inline-reach.top.to-absolute()
        let dn = ext.descent - inline-reach.bottom.to-absolute()
        let wd = measure(it).width
        let struts = {
          if up > 0pt { box(width: 0pt, height: cap + up) }
          if dn > 0pt { box(width: 0pt, height: dn, baseline: dn) }
        }
        let tall = up > 0pt or dn > 0pt
        if wd > inline-flush.to-absolute() {
          // Wide formulas stay breakable, so they cannot be boxed; strut both
          // ends instead (word joiners keep the struts on the formula's first
          // and last line).
          if tall { struts + sym.wj + it + sym.wj + struts } else { it }
        } else {
          // Fixed at its natural width too: in a narrow table cell a box of
          // auto width would wrap the formula onto a second line *inside* its
          // one-line height, drawing it over the next row.
          let core = box(height: cap, width: wd, it)
          if tall { box(struts + core) } else { core }
        }
      } }
    }
  }
  set par(justify: true, leading: 0.72em, first-line-indent: (amount: 0em, all: false))

  // Figure captions: smaller, justified, left-aligned; figures float to the
  // top of the page.
  show figure.caption: set text(size: 0.8em, fill: _caption-ink)
  show figure.caption: set align(left)
  show figure.caption: set par(justify: true, first-line-indent: 0pt)
  set figure(placement: top)

  // Captioned TABLES (`#figure(table(..), caption: ..)`) sit in place rather
  // than float, and may break across pages — a long table then continues, with
  // its header row repeated, onto the next page. (Raw `table` / `btable` not
  // wrapped in a figure already break by default; only figures need this.)
  // Floating and breaking are mutually exclusive, so tables opt out of the
  // float above. Image figures keep floating.
  show figure.where(kind: table): set figure(placement: none)
  show figure.where(kind: table): set block(breakable: true)
  // btable rules and row tints in the chapter's tab colour (see btable).
  show table: it => context _btable-colors(it, _chapter-color())

  // Per-chapter figure & table numbers: "Figure 2.3" / "Table 2.3" (or an
  // appendix "2.A.3"). The counters restart each chapter in the level-1 heading
  // rule; @references are corrected in the `show ref` below. `n` is this
  // figure's own kind counter, so images and tables number independently.
  set figure(numbering: if fig-per-chapter {
    n => context { _chap-num(here(), n, fig-numbering, fig-numbering-app) }
  } else { "1" })

  // Citations, cross-references, and URLs render as coloured clickable links.
  show ref: set text(fill: lc)
  show cite: set text(fill: lc)
  show link: set text(fill: lc)

  // ---- Cross-reference fix-ups ----------------------------------------------
  // All three are needed because Typst resolves a reference's number at the
  // CITATION site, not at the target:
  //   • appendix headings carry numbering: none (so they don't advance the
  //     chapter counter) and would otherwise be unreferenceable → render our
  //     own clickable "Appendix <chapter>.<letter>";
  //   • equation, figure and table numbers depend on the chapter/appendix
  //     region, so a cross-chapter or cross-region @ref would show the wrong
  //     chapter or a spurious "N.A" → recompute from the TARGET's own location.
  // Everything else falls through to the default.
  show ref: it => {
    let el = it.element
    if el == none { return it }
    if el.func() == heading {
      context {
        if _apphead.at(el.location()) {
          link(el.location(), text(fill: lc)[Appendix #_app-num(el.location())])
        } else { it }
      }
    } else if eq-per-chapter and el.func() == math.equation and el.numbering != none {
      context {
        let loc = el.location()
        link(loc, text(fill: lc)[Equation #_eq-num(loc, eq-numbering, eq-numbering-app)])
      }
    } else if fig-per-chapter and el.func() == figure and el.numbering != none {
      context {
        let supp = if el.kind == table { [Table] } else { [Figure] }
        link(el.location(), text(fill: lc)[#supp~#_fig-num(el, fig-numbering, fig-numbering-app)])
      }
    } else { it }
  }

  // ---- Page set-up ------------------------------------------------------------
  set page(
    // A custom trim wins over the named paper when both dimensions are given.
    ..(if page-width != auto and page-height != auto {
         (width: page-width, height: page-height)
       } else { (paper: paper) }),
    margin: margin,
    bleed: if type(bleed) == dictionary { bleed } else { (inside: 0pt, rest: bleed) },
    numbering: "1",
    number-align: top + right,
    header: _running-header(heading-font, margin),
    background: _side-tabs(
      accent: accent, font: heading-font, side: tab-side,
      pattern: tab-numbering, front-pattern: tab-numbering-front,
      back-pattern: tab-numbering-back, size: tab-label-size,
      active-fill: tab-active-fill,
      label-color: tab-label-color, colors: tab-colors,
      front-colors: tab-colors-front, back-colors: tab-colors-back,
    ),
    foreground: _flipbook(flipbook, flipbook-size, tab-side, flipbook-guide) + _trim-guide,
  )

  // ---- Headings ---------------------------------------------------------------
  show heading: set text(font: heading-font)
  show heading.where(level: 2): it => {
    set text(size: 10pt, weight: "semibold")
    set block(above: 1.5em)
    set block(below: 1em)
    it
  }
  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "light", style: "italic")
    set block(below: 1em)
    it
  }
  // Level 4 (====): same look as a sub-subsection, one point smaller.
  show heading.where(level: 4): it => {
    set text(size: 9pt, weight: "light", style: "italic")
    set block(below: 1em)
    it
  }
  set heading(numbering: "1.1")

  // Level-1 headings open chapters: "Chapter N ∘ Title" (centred, raised,
  // dashed rule) or "Appendix N.X ⋄ Title"; unnumbered ones (front/back
  // matter) render plainly. Part headings render nothing here — the divider
  // page is drawn by part() itself.
  show heading.where(level: 1): it => context {
    if _ispart.get() { return }
    let is-app = _apphead.get()
    // Only the FIRST appendix of a chapter opens on a fresh page; subsequent
    // appendices flow on directly after the previous one ends.
    let app-follows = is-app and counter("chap-app").get().first() > 1
    if not app-follows { pagebreak(weak: true) }
    // Equations, figures and tables all restart their count per chapter/appendix.
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    let is-chapter = (not is-app) and (it.numbering != none)
    // Unnumbered sections of the front and back matter get a side tab.
    if not is-app and it.numbering == none and _matter.get() in ("front", "back") { _tabmark(_matter.get()) }
    if is-chapter {
      counter("chap-app").update(0)   // appendix letters restart per chapter
      counter(footnote).update(0)     // footnotes restart at 1 each chapter (its
                                      //  appendices continue the chapter's run)
    }

    // Pull the title toward the page top. NOTE: emitted for every rendered
    // level-1 heading — as v(0pt) for appendices — because even a zero-height
    // spacer takes part in block-spacing collapse; dropping it shifts pages.
    v(if is-app { if app-follows { 0.5cm } else { 0pt } } else { chapter-raise })
    if is-chapter {
      // Centred opener: "Chapter N" kicker stacked over the title, dashed rule.
      let cn = numbering("1", counter(heading).get().first())
      block(below: 0.9cm, width: 100%)[
        #set par(justify: false, first-line-indent: 0pt, leading: 0.5em)
        #set align(center)
        #text(size: 11pt, fill: accent, weight: "black", tracking: 0.5pt)[$diamond.stroked.small$ Chapter #cn $diamond.stroked.small$]
        #v(-0.25cm)
        #text(size: 16pt, tracking: -0.5pt, weight: "medium")[#it.body]
        #v(-0.2cm)
        #align(center, line(length: 100%, stroke: (paint: accent, thickness: 0.3pt, dash: "densely-dashed")))
      ]
      // Automatic mini-TOC (global default + per-chapter minitoc-next override).
      let ov = _mtoc.get()
      _mtoc.update(auto)
      if (if ov == auto { chapter-minitoc } else { ov }) { minitoc() }
    } else {
      let head = if is-app {
        (text(fill: accent, weight: "light")[Appendix #_app-num(here())]
          + h(0.4em) + $diamond.stroked.small$ + h(0.4em)
          + text(weight: "medium")[#it.body])
      } else {
        text(weight: "medium")[#it.body]
      }
      block(below: 0.9cm)[
        #set par(justify: false, first-line-indent: 0pt)
        #text(size: 16pt, head)
      ]
    }
  }

  // ---- Table-of-contents entries ------------------------------------------------
  // Level 1 handles three cases: part rows (centred, coloured), per-chapter
  // appendix rows (styled and indented exactly like a section row, labelled
  // "<chapter>.A"), and ordinary chapter rows.
  show outline.entry.where(level: 1): it => {
    if it.element != none and it.element.func() == heading {
      context {
        let loc = it.element.location()
        if _ispart.at(loc) {
          let pn = numbering("I", counter("part").at(loc).first())
          v(13pt, weak: true)
          align(center, text(font: heading-font, size: 9pt, weight: "light", fill: part-color)[
            Part #pn #h(0.2em) $diamond.stroked.small$ #h(0.2em) #it.element.body
          ])
          v(5pt, weak: true)
        } else if _apphead.at(loc) {
          // An appendix is a level-1 heading shown at SECTION depth: one indent
          // step in, lettered "<chapter>.A", styled exactly like a section row.
          pad(left: _toc-indent, text(size: 10.5pt, fill: _toc-ink-2,
            it.indented([#_app-num(loc)], it.inner())))
        } else {
          v(10pt, weak: true)
          text(font: heading-font, size: 11.5pt, weight: "light", tracking: -0.05pt, fill: _toc-ink, it)
        }
      }
    } else { it }
  }
  show outline.entry.where(level: 2): it => _toc-sub(it, _toc-ink-2)
  show outline.entry.where(level: 3): it => _toc-sub(it, _toc-ink-3)
  show outline.entry.where(level: 4): it => _toc-sub(it, _toc-ink-3)

  // ---- Publish the configuration to the shared state ---------------------------
  _accent.update(accent)
  _tabcolors.update(tab-colors)
  _headfont.update(heading-font)
  _chapraise.update(chapter-raise)
  _trimguide.update(trim-guide)

  // ---- Equation numbering -------------------------------------------------------
  // "(<chapter>.<n>)" in chapters, "(<chapter>.<letter>.<n>)" in appendices —
  // via the shared `_eq-num`. At the tag, `here()` is the equation, so it reads
  // its own counters; @references reuse `_eq-num` at the equation's location in
  // the `show ref` rule above, so tag and reference can never disagree.
  if eq-per-chapter {
    set math.equation(numbering: _ => context { _eq-num(here(), eq-numbering, eq-numbering-app) })
    body
  } else {
    body
  }
}
