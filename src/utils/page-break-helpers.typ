// Smart page break helper functions for Windsor CLI book

// Smart page break - only breaks if insufficient space remaining
#let smart-break(min-space: 44pt) = {  // Convert 4em to pt (4em ≈ 44pt)
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

// Keep heading with following content (prevents orphaned headings)
#let section-with-content(heading-content, body-content) = {
  block(
    breakable: false,
    above: 1.5em,
    below: 0.4em,
    [
      #heading-content
      #v(0.4em)
      #body-content
    ]
  )
}

// Simple syntax highlighting for bash commands
#let highlight-bash(content) = {
  let lines = content.split("\n")
  let highlighted = ()

  for line in lines {
    let words = line.split(" ")
    let highlighted-line = ()

    for (i, word) in words.enumerate() {
      if i == 0 {
        // First word is usually a command - make it blue
        if word in ("kubectl", "docker", "windsor", "ls", "grep", "cat", "echo", "cd", "pwd", "git", "npm", "yarn", "make", "sudo", "ssh", "curl", "wget") {
          highlighted-line.push(text(fill: rgb("#0066cc"), word))
        } else {
          highlighted-line.push(word)
        }
      } else if word.starts-with("--") or word.starts-with("-") {
        // Flags - make them green
        highlighted-line.push(text(fill: rgb("#22863a"), word))
      } else if word.starts-with("#") {
        // Comments - make them gray
        highlighted-line.push(text(fill: rgb("#6a737d"), word))
      } else {
        highlighted-line.push(word)
      }

      if i < words.len() - 1 {
        highlighted-line.push(" ")
      }
    }

    highlighted.push(highlighted-line.join())
    if line != lines.last() {
      highlighted.push("\n")
    }
  }

  highlighted.join()
}

// Custom code block that avoids raw() entirely
#let custom-code(content, lang: none) = {
  let line-count = content.split("\n").len()

  context {
    let remaining = page.height - here().position().y
    let estimated-height = line-count * 13.2pt + 33pt

    let should-break = line-count > 10 and estimated-height > remaining

    block(
      width: 100%,
      fill: rgb("#f6f8fa"),
      stroke: 1pt + rgb("#e1e4e8"),
      radius: 6pt,
      inset: 12pt,
      breakable: should-break,
      above: 1em,
      below: 1em,
      text(
        font: ("Monaco", "Courier New"),
        size: 0.9em,
        if lang == "bash" {
          highlight-bash(content)
        } else {
          content
        }
      )
    )
  }
}

// Smart code block that considers size and remaining space
#let smart-code(content, lang: none) = {
  custom-code(content, lang: lang)
}

// Output block for command results - lighter styling
#let output-block(content) = {
  custom-code(content)
}

// Command + output pair as unified block
#let command-with-output(command, output, lang: "bash") = {
  let total-lines = command.split("\n").len() + output.split("\n").len()

  context {
    let remaining = page.height - here().position().y
    let estimated-height = total-lines * 13.2pt + 66pt  // Account for both blocks

    let should-break = total-lines > 15 and estimated-height > remaining

    block(
      width: 100%,
      fill: rgb("#f6f8fa"),
      stroke: 1pt + rgb("#e1e4e8"),
      radius: 6pt,
      inset: 12pt,
      breakable: should-break,
      above: 1em,
      below: 1em,
      text(
        font: ("Monaco", "Courier New"),
        size: 0.9em,
        [
          #if lang == "bash" {
            highlight-bash(command)
          } else {
            command
          }
          #text("\n")
          #output
        ]
      )
    )
  }
}

// Example block that stays together when reasonable
#let example-block(title: "Example", content) = {
  let content-str = repr(content)
  let is-short = content-str.len() < 500

  block(
    width: 100%,
    fill: rgb("#f0f8ff"),
    stroke: (left: 3pt + rgb("#0066cc")),
    inset: (left: 1em, right: 1em, top: 0.8em, bottom: 0.8em),
    radius: (right: 4pt),
    breakable: not is-short,
    above: 1em,
    below: 1em,
    [
      #text(weight: "bold", fill: rgb("#0066cc"))[#title]
      #v(0.5em)
      #content
    ]
  )
}

// Warning/info box that stays together
#let info-box(content, type: "info") = {
  let colors = (
    info: (bg: rgb("#e6f3ff"), border: rgb("#0066cc")),
    warning: (bg: rgb("#fff3cd"), border: rgb("#856404")),
    error: (bg: rgb("#f8d7da"), border: rgb("#721c24"))
  )

  let color = colors.at(type, default: colors.info)

  block(
    width: 100%,
    fill: color.bg,
    stroke: (left: 3pt + color.border),
    inset: 1em,
    radius: (right: 4pt),
    breakable: false,
    above: 1em,
    below: 1em,
    content
  )
}

// List that prevents orphaned items
#let smart-list(..items) = {
  for item in items.pos() {
    block(
      above: 0.3em,
      below: 0.3em,
      breakable: true,
      [• #item]
    )
  }
}

// Numbered list with smart breaks
#let smart-enum(..items) = {
  for (i, item) in items.pos().enumerate() {
    block(
      above: 0.3em,
      below: 0.3em,
      breakable: true,
      [#(i + 1). #item]
    )
  }
}

// Section break with smart spacing
#let section-break() = {
  smart-break(min-space: 66pt)  // Convert 6em to pt (6em ≈ 66pt)
}

// Chapter transition helper
#let chapter-transition() = {
  pagebreak()
  v(2em)
}
