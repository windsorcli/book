# Windsor CLI Book - Multi-Format Publishing System

A comprehensive guide to **Unified Cloud Native Development with Windsor**, featuring a modern publishing pipeline that generates professional PDF, EPUB, HTML, and Markdown formats from a single Typst source.

## 📚 About This Book

This book provides a complete guide to using Windsor CLI for unified cloud-native development, covering infrastructure orchestration, blueprint-driven development, and multi-cloud deployment strategies.

## 🏗️ Publishing Architecture

This project uses a **Typst-first** approach with multi-format output:

- **Typst** → Professional PDF with beautiful typography
- **Typlite** → Converts Typst to Markdown
- **Pandoc** → Generates EPUB and HTML from Markdown

### Single Source of Truth
- **Primary source**: Typst files in `chapters/`
- **PDF generation**: Direct from Typst (preserves all formatting)
- **Digital formats**: Via Typlite → Pandoc conversion chain

## 🚀 Quick Start

### Prerequisites

Install all required tools:
```bash
task install-all
```

Or install individually:
```bash
task install-typst    # Install Typst
task install-typlite  # Install typlite
task install-pandoc   # Install pandoc
```

### Build All Formats

```bash
task all              # Build PDF, EPUB, HTML, and Markdown
```

All output files are generated in the `dist/` folder:
- `unified-cloud-native-development-with-windsor.pdf`
- `unified-cloud-native-development-with-windsor.epub`
- `unified-cloud-native-development-with-windsor.html`
- `unified-cloud-native-development-with-windsor.md`

## 📖 Available Tasks

### Build Tasks
- `task pdf` - Build PDF (with beautiful Typst typography)
- `task markdown` - Convert to Markdown using typlite
- `task epub` - Generate EPUB from Markdown
- `task html` - Generate HTML from Markdown
- `task all` - Build all formats (default)

### Development Tasks
- `task watch` - Watch for changes and rebuild PDF
- `task convert` - Build PDF and convert to images for inspection
- `task clean` - Remove all generated files

### Installation Tasks
- `task install-all` - Install all required tools
- `task install-typst` - Install Typst
- `task install-typlite` - Install typlite
- `task install-pandoc` - Install pandoc

## 📁 Project Structure

```
book/
├── chapters/                    # Source content
│   ├── preface/preface.typ
│   ├── chapter01/chapter01.typ
│   └── ...
├── dist/                        # Generated output files
│   ├── unified-cloud-native-development-with-windsor.pdf
│   ├── unified-cloud-native-development-with-windsor.epub
│   ├── unified-cloud-native-development-with-windsor.html
│   └── unified-cloud-native-development-with-windsor.md
├── main.typ                     # Main Typst file (for PDF)
├── main-lite.typ               # Simplified version (for typlite)
├── template.typ                # Professional book template
├── pandoc-metadata.yaml        # Metadata for EPUB/HTML
├── book.css                    # Styling for HTML output
└── Taskfile.yml                # Build automation
```

## 🎨 Typography & Design

### PDF Features (via Typst)
- **Professional typography** with Libertinus Serif font
- **Traditional book layout** with proper page numbering (Roman → Arabic)
- **Custom headers/footers** with book title and chapter names
- **Optimized spacing** for headers, paragraphs, and code blocks
- **High-quality typesetting** with TeX-level line breaking

### Digital Format Features
- **EPUB** - E-reader compatible with proper metadata
- **HTML** - Standalone web page with responsive design
- **Markdown** - Clean, portable format for documentation

## 🔧 Customization

### Modifying Typography
Edit `template.typ` to customize:
- Fonts and sizing
- Page layout and margins
- Header and footer styles
- Paragraph and heading spacing

### Updating Metadata
Edit `pandoc-metadata.yaml` to change:
- Book title and author
- Publication information
- EPUB metadata
- HTML styling options

### Styling HTML Output
Edit `book.css` to customize:
- Web typography
- Color scheme
- Layout and spacing
- Print styles

## 🚀 Automated Publishing

### GitHub Actions
The repository includes automated publishing via GitHub Actions:

1. **Triggered by**: Version tags (e.g., `v1.0.0`) or manual dispatch
2. **Builds**: All formats (PDF, EPUB, HTML, Markdown)
3. **Uploads**: Assets to GitHub releases via release-drafter

### Local Development
```bash
task watch    # Auto-rebuild PDF on changes
task all      # Build all formats
task clean    # Clean generated files
```

## 🛠️ Technical Details

### Tools Used
- **[Typst](https://typst.app/)** - Modern typesetting system
- **[Typlite](https://github.com/Myriad-Dreamin/tinymist)** - Typst to Markdown converter
- **[Pandoc](https://pandoc.org/)** - Universal document converter
- **[Task](https://taskfile.dev/)** - Build automation

### Why This Architecture?
1. **Best typography** - Typst provides superior PDF output
2. **Single source** - All content in Typst files
3. **Broad compatibility** - EPUB/HTML for digital distribution
4. **Fast builds** - Typst compiles 10x faster than LaTeX
5. **Modern toolchain** - All tools are actively maintained

## 📄 License

© 2025 Ryan VanGundy. All rights reserved.

## 🤝 Contributing

This book is about Windsor CLI. For contributions to the tool itself, visit the [Windsor CLI repository](https://github.com/windsorcli/windsor).

For book improvements, please open an issue or pull request.

---

**Happy reading! 📖**
