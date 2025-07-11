// Page break utility functions for better layout control

// Smart page break that only breaks if there's insufficient space
#let smart-pagebreak(min-space: 4em) = {
  // Check if we have enough space remaining on the page
  context {
    let remaining = page.height - here().position().y
    if remaining < min-space {
      pagebreak()
    }
  }
}

// Keep content together on same page
#let keep-together(content) = {
  block(breakable: false, content)
}

// Keep with next - prevents orphaned headings
#let keep-with-next(content, next-content) = {
  block(
    breakable: false,
    [#content
     #next-content]
  )
}

// Smart code block wrapper
#let smart-code-block(content, max-lines: 8) = {
  let line-count = content.split("\n").len()

  block(
    width: 100%,
    fill: rgb("#f6f8fa"),
    stroke: 1pt + rgb("#e1e4e8"),
    radius: 6pt,
    inset: 12pt,
    breakable: if line-count <= max-lines { false } else { true },
    raw(content)
  )
}

// Prevent widow/orphan lines in paragraphs
#let no-orphans(content) = {
  set par(
    // Prevent single lines at top/bottom of pages
    orphans: 2,
    widows: 2
  )
  content
}

// Section break with smart spacing
#let section-break(title, level: 2) = {
  // Ensure we have enough space for the heading plus some content
  smart-pagebreak(min-space: 6em)

  if level == 2 {
    block(
      above: 1.5em,
      below: 0.4em,
      breakable: false,
      text(size: 14pt, weight: "bold", fill: rgb("#2a2a2a"))[#title]
    )
  } else if level == 3 {
    block(
      above: 1.2em,
      below: 0.3em,
      breakable: false,
      text(size: 13pt, weight: "semibold", fill: rgb("#3a3a3a"))[#title]
    )
  }
}

// Example usage wrapper
#let example-block(content) = {
  // Keep examples together when possible
  let content-length = repr(content).len()

  block(
    width: 100%,
    fill: rgb("#f8f9fa"),
    stroke: (left: 3pt + rgb("#0066cc")),
    inset: (left: 1em, right: 1em, top: 0.8em, bottom: 0.8em),
    radius: (right: 4pt),
    breakable: if content-length < 500 { false } else { true },
    content
  )
}
