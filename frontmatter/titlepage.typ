// Title pages. Replace with the official title page your university supplies
// (for the UvA: the Office of the Beadle), which must be used unmodified.
#page(numbering: none, header: none, background: none, foreground: none)[
  #v(5cm)
  #align(center)[
    #text(size: 36pt)[Thesis title]
    #v(0.2cm)
    #text(size: 18pt, fill: luma(31%))[Subtitle]
  ]
  #v(4cm)
  #align(center, text(size: 15pt)[Your Name])
]
#page(numbering: none, header: none, foreground: none, fill: luma(95%))[
  #set text(size: 11pt)
  #sym.copyright Your Name \
  Thesis title \
  Doctoral thesis, University \ \
  ISBN: \
  Printed by:
  #align(bottom, text(size: 9pt)[
    Funding acknowledgement and other colophon text go here.
  ])
]
