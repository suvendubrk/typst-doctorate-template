// =============================================================================
//  main.typ — THE PARENT. Render this to build the whole thesis.
//  It applies the shared template (meta.typ) once and pulls in every piece.
// =============================================================================
#import "meta.typ": *

#show: conf

// A cross-reference to a chapter reads "Chapter N" rather than "Section N".
#show heading.where(level: 1): set heading(supplement: [Chapter])

// ---- front matter ----
#include "frontmatter/titlepage.typ"

#frontmatter[
  #tableofcontents()
  #include "frontmatter/preface.typ"
]

// ---- main matter ----
#mainmatter[
  #part[The First Part]
  #include "chapters/ch1_example.typ"
  #part[The Second Part]
  #include "chapters/ch2_example.typ"
]

// ---- back matter ----
#backmatter[
  #include "backmatter/contributions.typ"
  #include "backmatter/summary.typ"
  #include "backmatter/samenvatting.typ"
  #include "backmatter/acknowledgements.typ"
  #bibliography("references.bib", title: "Bibliography", style: "template/aps-doi.csl")
]
