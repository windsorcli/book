// Professional book template for Windsor CLI documentation
#let book-template(
  title: "",
  subtitle: "",
  author: "",
  date: "",
  paper: "us-letter",
  margin: (
    top: 1in,
    bottom: 1in,
    left: 1in,
    right: 1in
  ),
  body
) = {
  // Document setup
  set document(
    title: title,
    author: author,
    date: auto
  )

  // Page setup
  set page(
    paper: paper,
    margin: margin,
    header: context {
      // Only show headers after the first page
      if counter(page).get().first() > 1 {
        let page-num = counter(page).get().first()
        let is-even = calc.even(page-num)

        v(12pt)

        if is-even {
          align(left, text(size: 9pt, fill: gray.darken(20%))[#title])
        } else {
          align(right, text(size: 9pt, fill: gray.darken(20%))[
            #context {
              let headings = query(heading.where(level: 1))
              if headings.len() > 0 {
                let current-heading = headings.last()
                // Check if the current heading has numbering
                if current-heading.numbering != none {
                  let chapter-num = counter(heading).get().first()
                  if chapter-num > 0 {
                    "Chapter " + str(chapter-num) + ": " + current-heading.body
                  } else {
                    current-heading.body
                  }
                } else {
                  current-heading.body
                }
              } else {
                "Chapter"
              }
            }
          ])
        }

        v(8pt)
        line(length: 100%, stroke: 0.5pt + gray)
      }
    },
    footer: context {
      // Only show page numbers after the first page
      if counter(page).get().first() > 1 {
        line(length: 100%, stroke: 0.5pt + gray)
        v(8pt)
        align(center, text(size: 9pt, fill: gray.darken(20%))[
          #counter(page).display()
        ])
        v(12pt)
      }
    }
  )

  // Professional typography with quality serif font
  set text(
    font: ("Libertinus Serif", "Times New Roman", "Times"),
    size: 11pt,
    lang: "en"
  )

  // Paragraph styling - more reasonable spacing
  set par(
    leading: 0.75em,
    first-line-indent: 0pt,
    justify: true,
    spacing: 1.6em,
    hanging-indent: 0pt
  )

  // Enable heading numbering for chapters
  set heading(numbering: "1.")

  // Heading styling - clean chapter pages
  show heading.where(level: 1): it => {
    pagebreak()
    v(3em)

    align(center)[
      #if it.numbering != none {
        text(size: 16pt, weight: "regular", fill: rgb("#666666"))[
          Chapter #counter(heading).display()
        ]
        v(1em)
      }
      #text(size: 24pt, weight: "bold", fill: rgb("#1a1a1a"))[#it.body]
    ]

    v(2.5em)
  }

  // Control header spacing independently from paragraph spacing
  show heading.where(level: 2): set block(above: 1.5em, below: 0.4em)
  show heading.where(level: 2): it => {
    text(size: 14pt, weight: "bold", fill: rgb("#2a2a2a"))[#it.body]
  }

  show heading.where(level: 3): set block(above: 1.2em, below: 0.3em)
  show heading.where(level: 3): it => {
    text(size: 13pt, weight: "semibold", fill: rgb("#3a3a3a"))[#it.body]
  }

  // Code block styling - modern with better contrast
  show raw.where(block: true): it => {
    set text(font: ("Monaco", "Menlo", "Courier New"), size: 9pt)
    block(
      width: 100%,
      fill: rgb("#f6f8fa"),
      stroke: 1pt + rgb("#e1e4e8"),
      radius: 6pt,
      inset: 12pt,
      breakable: true,
      it
    )
  }

  // Inline code styling
  show raw.where(block: false): it => {
    box(
      fill: rgb("#f6f8fa"),
      stroke: 1pt + rgb("#e1e4e8"),
      outset: (x: 3pt, y: 2pt),
      radius: 3pt,
      text(font: ("Monaco", "Menlo", "Courier New"), size: 9pt, it)
    )
  }

  // List styling - professional appearance
  set list(
    indent: 1em,
    body-indent: 0.8em,
    spacing: 0.6em,
    tight: false,
    marker: ([•], [◦], [‣])
  )

  set enum(
    indent: 1em,
    body-indent: 0.8em,
    spacing: 0.6em,
    tight: false
  )

  // Quote styling - sleek modern design
  show quote: it => {
    set text(style: "italic", fill: rgb("#4a4a4a"))
    set par(first-line-indent: 0pt)
    block(
      width: 100%,
      inset: (left: 1.5em, right: 1.5em, top: 1em, bottom: 1em),
      stroke: (left: 3pt + rgb("#0066cc")),
      fill: rgb("#f8f9fa"),
      radius: (left: 0pt, right: 4pt, top: 4pt, bottom: 4pt),
      breakable: true,
      it.body
    )
  }

  // Link styling
  show link: it => {
    text(fill: rgb("#0066cc"), it)
  }

  // Strong text (bold)
  show strong: it => {
    text(weight: "bold", fill: rgb("#1a1a1a"), it)
  }

  // Emphasis (italic)
  show emph: it => {
    text(style: "italic", fill: rgb("#2a2a2a"), it)
  }

  // Table styling
  show table: it => {
    set text(size: 9.5pt)
    set table(
      stroke: 1pt + rgb("#e1e4e8"),
      fill: (x, y) => if calc.even(y) { rgb("#f6f8fa") } else { white }
    )
    block(breakable: true, it)
  }

  // Figure styling
  show figure: it => {
    set text(size: 9pt, fill: rgb("#4a4a4a"))
    v(1.2em)
    it
    v(1.2em)
  }

  body
}
