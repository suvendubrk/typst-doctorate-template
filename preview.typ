// =============================================================================
//  preview.typ — preview ONE file on its own, with the real thesis styling.
//
//  CLI:    typst compile preview.typ out.pdf --input file=chapters/ch1_example.typ
//  Python: typst.compile("preview.typ", output="out.pdf",
//                        sys_inputs={"file": "chapters/ch1_example.typ"})
//
//  Defaults to chapter 1 if no file is given.
// =============================================================================
#import "meta.typ": *

#show: conf

// Single-file preview tolerance: a chapter often references labels defined in
// OTHER files (e.g. an equation "of the previous chapter"). Compiling it alone
// those labels don't exist and Typst would hard-error, blocking the whole
// preview. Catch such refs and render a visible placeholder instead. The real
// main.typ build includes every file, so genuinely broken references still
// error there — this leniency applies only to isolated previews.
//
// A ref is left alone if it resolves to (a) a label present in this file, or
// (b) a bibliography key (a citation) — otherwise it points to another file and
// gets the placeholder. The bib keys are read straight from the .bib so real
// citations keep working; keep this path in sync with the #bibliography below.
#let _bib-keys = read("references.bib").matches(regex("@\w+\{([^,\s]+)")).map(m => m.captures.first())
#show ref: it => {
  if query(it.target).len() > 0 or _bib-keys.contains(str(it.target)) {
    it
  } else {
    box(inset: (x: 3pt), outset: (y: 1pt), radius: 2pt, fill: rgb("#fff0b3"),
      text(size: 0.8em, fill: rgb("#8a5a00"))[↗ #str(it.target)])
  }
}

#let target = sys.inputs.at("file", default: "/chapters/ch1_example.typ")
#include target

#pagebreak()
// Load the database so any @citations in the previewed file resolve.
// (title: none → nothing shows when the file has no citations.)
#bibliography("references.bib", title: none, style: "template/aps-doi.csl")
