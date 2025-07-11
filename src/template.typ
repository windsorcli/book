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

  // Limit PDF outline/bookmark depth to 2 levels for academic text standards
  set outline(depth: 2)

  // State to track troubleshooting sections
  let troubleshooting-mode = state("troubleshooting", false)

  // Page setup with improved page break handling
  set page(
    paper: paper,
    margin: margin,
    background: context {
      // Show red edge tab when in troubleshooting mode
      if troubleshooting-mode.get() {
        place(
          right + top,
          dx: 0pt,
          dy: 12%,
          rect(
            width: 8pt,
            height: 30%,
            fill: rgb("#8b4513"),
            stroke: none
          )
        )
      }
    },
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

  // Professional typography with quality serif font and widow/orphan control
  set text(
    font: ("Libertinus Serif", "Times New Roman", "Times"),
    size: 11pt,
    lang: "en"
  )

  // Paragraph styling with improved page break control
  set par(
    leading: 0.8em,  // Line spacing within paragraphs
    first-line-indent: 0pt,
    justify: true,
    spacing: 1.3em,  // Reduced from 1.4em for tighter normal line spacing
    hanging-indent: 0pt
  )

  // Enable heading numbering for chapters and sections only (levels 1-2)
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level == 1 {
      numbering("1.", ..nums)
    } else if level == 2 {
      numbering("1.1.", ..nums)
    } else {
      // No numbering for level 3+ headings
      none
    }
  })

  // Heading styling with smart page break prevention
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

  // Level 2 headings with page break prevention - keep with following content
  show heading.where(level: 2): it => {
    // Add space before if not at top of page, prevent orphaning
    block(
      above: 1.8em,  // Increased from 1.5em for better section separation
      below: 0.9em,  // Increased from 0.8em for better spacing
      breakable: false,
      sticky: true,  // Keep with following content
      text(size: 14pt, weight: "bold", fill: rgb("#2a2a2a"))[#it.body]
    )
  }

  // Level 3 headings with page break prevention
  show heading.where(level: 3): it => {
    block(
      above: 1.4em,  // Increased from 1.2em for better section separation
      below: 0.7em,  // Increased from 0.6em for better spacing
      breakable: false,
      sticky: true,  // Keep with following content
      text(size: 13pt, weight: "semibold", fill: rgb("#3a3a3a"))[#it.body]
    )
  }

  // Code block styling with intelligent page break handling
  show raw.where(block: true): it => {
    set text(font: ("Monaco", "Menlo", "Courier New"), size: 9pt)
    set par(leading: 0.65em)  // Tighter line spacing within code blocks

    // Estimate content size for break decisions
    let content = it.text
    let line-count = content.split("\n").len()

    // Use context to check available space
    context {
      let remaining-space = page.height - here().position().y
      let estimated-height = line-count * 13.2pt + 22pt  // Convert em to pt (1.2em ≈ 13.2pt, 2em ≈ 22pt)

      // If code block is small or would fit, don't break
      let should-break = line-count > 12 and estimated-height > remaining-space

      block(
        width: 100%,
        fill: rgb("#f6f8fa"),
        stroke: 1pt + rgb("#e1e4e8"),
        radius: 6pt,
        inset: 14pt,  // Increased from 12pt for better internal spacing
        breakable: should-break,
        above: 1.3em,  // Increased from 1.2em for better separation
        below: 1.3em,  // Increased from 1.2em for better separation
        it
      )
    }
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

  // List styling with better page break control
  set list(
    indent: 1.2em,  // Increased from 1em for better bullet separation
    body-indent: 0.9em,  // Increased from 0.8em for better text alignment
    spacing: 0.8em,  // Match paragraph line spacing (0.8em leading)
    tight: false,  // Back to normal spacing between list and surrounding content
    marker: ([•], [◦], [‣])
  )

  // Override list item formatting with proper spacing
  show list.item: it => {
    block(
      breakable: true,
      above: 0.6em,  // More space above each list item
      below: 0.4em,  // Normal space below
      {
        set par(leading: 0.75em, spacing: 0em)  // Zero paragraph spacing within items
        set text(size: 11pt)  // Match body text size
        it
      }
    )
  }

  // Add proper spacing above the entire list
  show list: it => {
    block(
      above: 1em,  // Proper separation from preceding paragraph
      below: 0.8em,  // Normal separation after list
      it
    )
  }

  set enum(
    indent: 1.2em,  // Increased to match list indent
    body-indent: 0.9em,  // Increased to match list body-indent
    spacing: 0.8em,  // Match paragraph line spacing (0.8em leading)
    tight: false  // Back to normal spacing
  )

  // Override enum item formatting with proper spacing
  show enum.item: it => {
    block(
      breakable: true,
      above: 0.6em,  // More space above each enum item
      below: 0.4em,  // Normal space below
      {
        set par(leading: 0.75em, spacing: 0em)  // Zero paragraph spacing within items
        set text(size: 11pt)  // Match body text size
        it
      }
    )
  }

  // Add proper spacing above the entire enum
  show enum: it => {
    block(
      above: 1em,  // Proper separation from preceding paragraph
      below: 0.8em,  // Normal separation after enum
      it
    )
  }

  // Quote styling with page break control
  show quote: it => {
    set text(style: "italic", fill: rgb("#4a4a4a"))
    set par(first-line-indent: 0pt)

    // Keep quotes together when reasonable
    let content-length = repr(it.body).len()

    block(
      width: 100%,
      inset: (left: 1.5em, right: 1.5em, top: 1em, bottom: 1em),
      stroke: (left: 3pt + rgb("#0066cc")),
      fill: rgb("#f8f9fa"),
      radius: (left: 0pt, right: 4pt, top: 4pt, bottom: 4pt),
      breakable: if content-length < 400 { false } else { true },
      above: 1em,
      below: 1em,
      it.body
    )
  }

  // Link styling
  show link: it => {
    text(fill: rgb("#0066cc"), it)
  }

  // Strong text (bold) with better spacing for definition-style text
  show strong: it => {
    // Check if this looks like a definition header (ends with colon)
    let content-str = repr(it.body)
    if content-str.ends-with(":") {
      // Definition-style bold text gets a bit more space after
      text(weight: "bold", fill: rgb("#1a1a1a"))[#it.body] + h(0.3em)
    } else {
      text(weight: "bold", fill: rgb("#1a1a1a"), it)
    }
  }

  // Emphasis (italic)
  show emph: it => {
    text(style: "italic", fill: rgb("#2a2a2a"), it)
  }

  // Table styling with smart page break prevention
  show table: it => {
    set text(size: 9.5pt)
    set table(
      stroke: 1pt + rgb("#e1e4e8"),
      fill: (x, y) => if calc.even(y) { rgb("#f6f8fa") } else { white },
      inset: 8pt  // Add internal padding to table cells
    )

    // Estimate table size for break decisions
    let row-count = it.children.len()

    block(
      // Small tables stay together, large ones can break
      breakable: if row-count < 8 { false } else { true },
      above: 1.4em,  // Increased from 1em for better separation
      below: 1.4em,  // Increased from 1em for better separation
      it
    )
  }

  // Figure styling with page break control
  show figure: it => {
    set text(size: 9pt, fill: rgb("#4a4a4a"))

    // Keep figures with captions together
    block(
      breakable: false,
      above: 1.5em,  // Increased from 1.2em for better separation
      below: 1.5em,  // Increased from 1.2em for better separation
      [
        #it.body
        #v(0.4em)  // Add space between figure and caption
        #if it.caption != none {
          align(center)[
            #text(size: 9pt, style: "italic")[#it.caption]
          ]
        }
      ]
    )
  }

  body
}

// Custom styled subheading that doesn't appear in ToC
#let subheading(content) = {
  block(
    above: 1.4em,
    below: 0.7em,
    breakable: false,
    sticky: true,
    text(size: 13pt, weight: "semibold", fill: rgb("#3a3a3a"))[#content]
  )
}

// Helper functions for troubleshooting sections
#let troubleshooting-start() = {
  state("troubleshooting", false).update(true)
}

#let troubleshooting-end() = {
  state("troubleshooting", false).update(false)
}
