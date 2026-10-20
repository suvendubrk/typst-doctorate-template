// =============================================================================
//  _guide.typ — helpers used only by the author's guide (the example chapters).
//  Delete this file together with the guide chapters when you start writing.
// =============================================================================
#import "../meta.typ": *
#import "../meta.typ" as _m

// Everything meta.typ exports, so examples can call the template's commands.
#let _scope = dictionary(_m)

#let _code-box(src) = block(
  width: 100%, fill: luma(96%), inset: (x: 9pt, y: 7pt), radius: 3pt,
  text(size: 0.8em, raw(src.trim(), lang: "typ", block: true)),
)
#let _out-box(body) = block(
  width: 100%, inset: (left: 10pt, y: 5pt), stroke: (left: 1.5pt + luma(78%)), body,
)

// Source and result of a snippet. Pass a ```typ raw block```; it is shown
// verbatim and then evaluated in markup mode with the template in scope.
//   side: true puts source and result next to each other.
#let example(code, side: false) = {
  let src = code.text
  let out = eval(src, mode: "markup", scope: _scope)
  block(width: 100%, above: 1.1em, below: 1.1em, breakable: false,
    if side {
      grid(columns: (1fr, 1fr), column-gutter: 10pt, align: horizon, _code-box(src), _out-box(out))
    } else {
      _code-box(src); v(-0.3em); _out-box(out)
    })
}

// Source only, for snippets that change the whole document (headings, matters,
// show rules) and so cannot be rendered in place.
#let code(c) = block(width: 100%, above: 1em, below: 1em, _code-box(c.text))

// Inline name of a command or option.
#let cmd(name) = raw(name, lang: none)

// A reference table: `header` is a tuple of column titles, rows follow.
#let reftable(columns: (auto, auto, 1fr), header: (), ..rows) = {
  set text(size: 0.86em)
  set par(justify: false)
  btable(columns: columns, align: (left + top,) * columns.len(), inset: (x: 6pt, y: 5pt), header: header.map(h => text(weight: "bold", h)), ..rows)
}
