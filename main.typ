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
  #part[Using the Template]
  #include "chapters/ch1_start.typ"
  #include "chapters/ch2_structure.typ"
  #include "chapters/ch3_config.typ"
  #include "chapters/ch4_maths.typ"
  #include "chapters/ch5_floats.typ"
  #include "chapters/ch6_refs.typ"
  #part[Changing the Template]
  #include "chapters/ch7_internals.typ"
]

// ---- back matter ----
#backmatter[
  #include "backmatter/contributions.typ"
  #include "backmatter/summary.typ"
  #include "backmatter/samenvatting.typ"
  #include "backmatter/acknowledgements.typ"
  #bibliography("references.bib", title: "Bibliography", style: "template/aps-doi.csl")
]
