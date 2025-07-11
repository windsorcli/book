#import "/src/template.typ": *
#import "/src/utils/page-break-helpers.typ": *

// Configure the document
#show: book-template.with(
  title: "Unified Cloud Native Development with Windsor",
  subtitle: "A Comprehensive Guide to Infrastructure Orchestration",
  author: "Ryan VanGundy",
  date: datetime.today().display("[month repr:long] [day], [year]"),
)

// Cover page
#set page(numbering: none)
#page[
  #v(1.5fr)

      // Single column layout with floating image
  #text(48pt, weight: "bold", fill: rgb("#2d3748"))[
    Unified Cloud Native\
    Development
  ]

  #v(1.5em)

  #text(38pt, weight: "bold", fill: rgb("#8b4513"))[
    with Windsor
  ]

      // Floating image positioned independently (behind text)
  #place(
    right + bottom,
    dx: -1.5em,
    dy: -8em,
    [#image("/chapters/cover_image.png", width: 180pt)]
  )

    #v(2.5em)

  #text(18pt, weight: "regular", fill: rgb("#4a5568"), style: "italic")[
    A Comprehensive Guide to\
    Infrastructure Orchestration
  ]

  #v(2.5fr)

  // Author at bottom left for separation
  #grid(
    columns: (2fr, 1fr),
    [
      #text(17pt, weight: "semibold", fill: rgb("#2d3748"))[
        Ryan VanGundy
      ]

      #v(0.7em)

      #text(11pt, weight: "regular", fill: rgb("#718096"))[
        Published #datetime.today().display("[month repr:long] [day], [year]")
      ]
    ],
    []
  )

  #v(1fr)
]

// Table of contents with Roman numerals
#set page(numbering: "i")
#counter(page).update(1)

// Generate the outline with built-in title
#outline(
  title: align(center)[
    #text(18pt, weight: "bold", fill: rgb("#1a1a1a"))[Table of Contents]
  ],
  depth: 2,
  indent: auto
)

#set heading(numbering: none)
#include "/chapters/preface/preface.typ"

// Reset page numbering to Arabic numerals for chapters
#set page(numbering: "1")
#counter(page).update(1)

#set heading(numbering: "1.")
#include "/chapters/chapter01/chapter01.typ"
// #include "/chapters/chapter02/chapter02.typ"
// #include "/chapters/chapter03/chapter03.typ"
