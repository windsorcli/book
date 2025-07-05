// Simplified version for typlite conversion
// This removes template complexities that typlite can't handle

#set text(
  font: "Libertinus Serif",
  size: 11pt,
  lang: "en",
  region: "US",
)

#set par(
  leading: 0.75em,
  first-line-indent: 0pt,
  justify: true,
  spacing: 1.6em,
)

#set heading(numbering: "1.")

// Title page
#align(center)[
  #text(size: 24pt, weight: "bold")[
    Unified Cloud Native Development with Windsor
  ]

  #v(1em)

  #text(size: 16pt)[
    A Comprehensive Guide to Infrastructure Orchestration
  ]

  #v(2em)

  #text(size: 12pt)[
    Ryan VanGundy
  ]

  #v(1em)

  #text(size: 12pt)[
    #datetime.today().display()
  ]
]

#pagebreak()

// Note: Table of Contents is generated automatically by Pandoc for HTML/EPUB
// No need for Typst's outline() here as it creates redundant static TOC

// Include content
#include "chapters/preface/preface.typ"
