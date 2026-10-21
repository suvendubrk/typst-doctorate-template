// =============================================================================
//  meta.typ — one place for shared settings, helpers, and the template config.
//  Every chapter/section/front-matter file imports THIS (not the template
//  directly), so they all share the same functions, macros, and styling.
// =============================================================================

// Bring in the template (re-exported to every file that imports meta.typ).
// The generic helpers — thesis(), part(), chapter-appendix(), btable(), ket/
// bra/bigO, concept, boxeq, subfigure, … — all live in the template and reach
// the chapters through this re-export. Only project-specific pieces are below.
#import "template/thesis.typ": *

// ---- Project-specific macros -------------------------------------------------
// Calligraphic alphabet from STIX Two Math: KpMath's own script glyphs are an
// ornate roundhand that reads poorly on screen. Only cal() switches font; all
// other maths stays in KpMath. Font-specific, so it stays here rather than in
// the template.
#let cal(body) = text(font: ("STIX Two Math", "New Computer Modern Math"), math.cal(body))

// ---- Tensor-product family ---------------------------------------------------
// This Typst build spells the circled operators `times.o`, `plus.o`, … — not
// the `times.circle` of the current docs, which is why they look absent. Going
// through the symbol names rather than raw ⊗/⊕ glyphs keeps the source free of
// exotic characters and lets Typst resolve the glyph itself (its own class,
// its own font fallback), which is more robust in previewers than a literal
// codepoint pinned to one font.
#let ox = sym.times.o            // tensor product        a ox b
#let oplus = sym.plus.o          // direct sum            a oplus b
#let oxbig = sym.times.o.big     // big tensor product    oxbig_(j=1)^N
#let oplusbig = sym.plus.o.big   // big direct sum        oplusbig_(k)
#let vac = sym.dot.o             // pseudo-vacuum         ket(vac)
#let novac = sym.slash.o         // unraised remainder    ket(novac)

// ---- Compact big operators ---------------------------------------------------
// Stacked limits (index under, bound over) make a display equation tall and
// airy, and in a multi-line equation they leave the lines looking ragged. This
// rule tucks the limits alongside the operator instead — ∑_(k=1)^3 rather than
// a three-storey Σ — which keeps dense equations flush with the surrounding
// text. Apply per chapter: `#show: compact-sums`.
// A multi-line limit, LaTeX's \substack. A long condition set on one line under
// a sum is wider than the operator itself, and the summand is then pushed out
// to clear it — the gap that opens between the ∑ and what follows. Splitting
// the condition over two short lines closes most of that gap, which is exactly
// how the source papers set these sums.
//   limits(sum)_(substack(abs({alpha}) + 2 abs({beta}), = N_+))
#let substack(..rows) = math.vec(delim: none, gap: 0.15em, ..rows)

// LaTeX's \smashoperator (mathtools). Even split over two lines a condition is
// usually wider than the ∑ it sits under, and that width — not any spacing —
// is what holds the summand away from the sign. Smashing lets the limit hang
// into the space beneath the neighbouring terms instead of pushing them out.
//
//   side: "r"    (default) only the right overhang is smashed, so the operator
//                keeps normal spacing after the preceding relation and the
//                summand still comes up snug. This is the one to reach for.
//   side: "l"    mirror image; "both" is LaTeX's default and closes the gap on
//                both sides, at the cost of crowding whatever precedes it.
//
// Pass a different `op` for other operators, e.g. op: $limits(product)$.
// Widths are measured in display style, which is where these sums live.
// The result is re-declared a large operator so Typst puts back the thin space
// a big operator takes before its summand — the negative kern would otherwise
// leave the summand touching the sign.
#let smashop(body, op: $limits(sum)$, side: "r") = context {
  let over = calc.max(0pt, (measure($ #body $).width - measure($ #op $).width) / 2)
  let smashed = if side == "l" { h(-over) + body } else if side == "both" {
    h(-over) + body + h(-over)
  } else { body + h(-over) }
  math.class("large", smashed)
}

#let compact-sums(body) = {
  show math.equation: eq => {
    show sym.sum: it => math.scripts(it)
    show sym.product: it => math.scripts(it)
    eq
  }
  body
}

// ---- Flush set braces ---------------------------------------------------------
// Typst stretches matched braces and bars to whatever they enclose, so a set
// like {α^(q)} (and its size |{α^(q)}|) grows taller than the letters around
// it, which stands out in sum limits. This rule draws such braces at their
// natural size, like LaTeX's \{ \}. Only braces around flat content (letters,
// scripts, relations) are touched, plus the bars of a set's size; braces around
// fractions, binomials or big operators still stretch. Apply per chapter:
// `#show: flush-sets`.
#let _tall-funcs = (math.frac, math.binom, math.vec, math.mat, math.cases, math.root, math.op)
#let _flat(c) = {
  if type(c) == array { return c.all(_flat) }
  if type(c) != content { return true }
  if c.func() in _tall-funcs { return false }
  if c.func() == symbol or c.func() == text {
    return c.at("text", default: "") not in ("∑", "∏", "∫", "⨂", "⨁")
  }
  c.fields().values().all(_flat)
}
#let _delims(it) = {
  let b = it.body
  if b.func() != [].func() or b.children.len() < 2 { return none }
  let (l, r) = (b.children.first(), b.children.last())
  (l.at("text", default: none), r.at("text", default: none))
}
#let _has-set(c) = {
  if type(c) == array { return c.any(_has-set) }
  if type(c) != content { return false }
  if c.func() == math.lr and _delims(c) == ("{", "}") { return true }
  c.fields().values().any(_has-set)
}

// The bare delimiters are re-declared opening/closing, as they would be inside
// lr(), so a bar keeps no stray space before a following "/2" or "=".
#let flush-sets(body) = {
  show math.lr: it => {
    let d = _delims(it)
    if (d == ("{", "}") or (d == ("|", "|") and _has-set(it.body))) and _flat(it.body) {
      let c = it.body.children
      math.class("opening", c.first()) + c.slice(1, -1).join() + math.class("closing", c.last())
    } else { it }
  }
  body
}

// ---- Figure placeholder ------------------------------------------------------
//  Stand-in for figures whose image files are not (yet) copied into the thesis.
//  Wrap in #figure(...) with the original caption and label.
#let placeholder-fig(height: 5.5cm) = rect(
  width: 100%, height: height,
  stroke: (paint: luma(55%), dash: "dashed", thickness: 0.6pt),
  fill: luma(97%),
  align(center + horizon, text(fill: luma(45%), style: "italic")[figure placeholder]),
)

// ---- Flip-book frame (swap for: image("images/frames/" + str(n) + ".png")) --
#let demo-flip(n) = {
  let t = calc.rem(n, 16) / 16
  let x = 100% * calc.abs(2 * t - 1)
  box(width: 100%, height: 100%,
    place(left + horizon, dx: x, circle(radius: 2.5pt, fill: rgb("#5A6C80"))))
}

// ---- THE shared template configuration --------------------------------------
//  Used by BOTH main.typ (full thesis) and preview.typ (single-file preview),
//  so a chapter always previews with the same look it has in the final build.
#let conf = thesis.with(
  // ---- PDF metadata ---------------------------------------------------------
  title: "typst-doctorate-template: Author's guide",
  author: "Suvendu Kumar Barik",
  // ---- FONTS: change these to use any installed font -----------------------
  //  A list gives fallbacks. Fonts not built into Typst go in ./fonts and are
  //  found with: typst compile --font-path fonts main.typ  (see README).
  font-size: 10pt,
  body-font: "Libertinus Serif",                          // built into Typst
  math-font: ("KpMath", "New Computer Modern Math"),      // Kepler (Light), else built-in
  heading-font: ("STIX Two Text", "Libertinus Serif"),
  // ---- Page: set the trim and margins your printer specifies ----------------
  page-width: 170mm,
  page-height: 240mm,
  margin: (inside: 24mm, outside: 20mm, top: 24mm, bottom: 22mm),
  theme: "black",
  link-color: rgb("#9F3D1A"),
  // ---- Side tabs: only the active chapter shows, as a single coloured tab --
  tab-numbering: "1",                // "1" | "A" | "a" | "i" | "I"
  tab-label-size: 14pt,
  tab-colors: (                      // one colour per chapter; cycles if shorter
    rgb("#64503c"), rgb("#503c52"), rgb("#313f64"), rgb("#757187"),
    rgb("#536478"), rgb("#626333"), rgb("#8C8A6F"), rgb("#66671e"),
    rgb("#743d1b"), rgb("#bd8678"),
  ),
  // front- and back-matter tabs, from the table of contents on
  tab-colors-front: (rgb("#6b201f"), rgb("#914845"), rgb("#a3705c")),
  tab-colors-back: (rgb("#ab6694"), rgb("#6d5480"), rgb("#28558b"), rgb("#31685b"), rgb("#617d14"), rgb("#a4671e")),
  // flipbook: demo-flip,
)
