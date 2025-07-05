#import "template.typ": *

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
    [#image("chapters/cover_image.png", width: 180pt)]
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

#pagebreak()

// Table of contents with Roman numerals
#set page(numbering: "i")
#counter(page).update(1)

#align(center)[
  #text(18pt, weight: "bold", fill: rgb("#1a1a1a"))[Table of Contents]
]

#v(2.5em)

// Professional table of contents with tighter spacing
#let toc-entry(title, page, level: 0) = {
  let indent = level * 1.5em
  let title-text = if level == 0 {
    text(weight: "bold", size: 12pt)[#title]
  } else {
    text(weight: "regular", size: 11pt)[#title]
  }

  h(indent) + title-text + h(1fr) + text(size: 11pt)[#page]
  linebreak()
  v(if level == 0 { 0.5em } else { 0.2em })
}

// Front matter entries
#toc-entry("Preface", "ii")
#toc-entry("Who This Book Is For", "ii", level: 1)
#toc-entry("What You'll Learn", "ii", level: 1)
#toc-entry("How to Use This Book", "iii", level: 1)
#toc-entry("A Note on the Cloud-Native Landscape", "iii", level: 1)
#toc-entry("Acknowledgments", "iii", level: 1)

#v(1em)

// Chapter entries

// Front matter (Preface) - Roman numerals continue, NO NUMBERING
#set heading(numbering: none)
#include "chapters/preface/preface.typ"

#pagebreak()

// Main content - Reset to Arabic numerals and ENABLE numbering for chapters
#counter(page).update(1)
#set page(numbering: "1")
#set heading(numbering: "1.")

// Chapters

// Add more chapters as needed
// #include "chapters/chapter02/chapter02.typ"
// #include "chapters/chapter03/chapter03.typ"
