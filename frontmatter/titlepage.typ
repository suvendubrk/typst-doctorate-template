// Title pages. Replace with your own; universities often supply an official
// title page (for the UvA: the Office of the Beadle) that must be used unchanged.
#page(numbering: none, header: none, background: none, foreground: none)[
  #v(5cm)
  #align(center)[
    #text(size: 30pt)[typst-doctorate-template]
    #v(0.3cm)
    #text(size: 16pt, fill: luma(31%))[Author's guide and reference]
  ]
  #v(4cm)
  #align(center, text(size: 13pt)[Suvendu Kumar Barik])
  #v(1fr)
  #align(center, text(size: 10pt, fill: luma(40%))[github.com/suvendubrk/typst-doctorate-template])
]
#page(numbering: none, header: none, foreground: none, fill: luma(95%))[
  #set text(size: 10pt)
  This page is the reverse of the title page. In a thesis it carries the
  copyright line, the printer and the funding acknowledgement.
  #v(1fr)
  #text(size: 9pt)[
    Released under the Creative Commons Attribution 4.0 International license.
    The citation style `template/aps-doi.csl` is adapted from the Citation
    Style Language project and remains under CC BY-SA 3.0.
  ]
]
