# Windsor CLI Book

A comprehensive guide to **Unified Cloud Native Development with Windsor**, published in multiple formats from a single source.

## About This Book

This book provides a complete guide to using Windsor CLI for unified cloud-native development, covering infrastructure orchestration, blueprint-driven development, and multi-cloud deployment strategies.

## Getting Started

### Prerequisites

Install required tools:
```bash
task install-all
```

### Build All Formats

```bash
task all
```

Output files are generated in `dist/`:
- `unified-cloud-native-development-with-windsor.pdf`
- `unified-cloud-native-development-with-windsor.epub`
- `unified-cloud-native-development-with-windsor.html`
- `unified-cloud-native-development-with-windsor.md`

## Available Tasks

### Build Tasks
- `task pdf` - Build PDF
- `task markdown` - Convert to Markdown
- `task epub` - Generate EPUB
- `task html` - Generate HTML
- `task all` - Build all formats

### Development Tasks
- `task watch` - Watch for changes and rebuild PDF
- `task clean` - Remove generated files

### Installation Tasks
- `task install-all` - Install all required tools
- `task install-typst` - Install Typst
- `task install-typlite` - Install typlite
- `task install-pandoc` - Install pandoc

## Project Structure

```
book/
├── chapters/                    # Source content
│   ├── preface/preface.typ
│   ├── chapter01/chapter01.typ
│   └── ...
├── dist/                        # Generated output files
├── main.typ                     # Main Typst file
├── main-lite.typ               # Simplified version for conversion
├── template.typ                # Book template
├── pandoc-metadata.yaml        # Metadata for digital formats
├── book.css                    # HTML styling
└── Taskfile.yml                # Build automation
```

## Customization

### Typography
Edit `template.typ` to customize fonts, layout, and styling.

### Metadata
Edit `pandoc-metadata.yaml` to change book information and publication details.

### HTML Styling
Edit `book.css` to customize web appearance.

## Automated Publishing

GitHub Actions automatically builds and publishes releases when tags are created:

1. Manual dispatch creates CalVer tag
2. Tag triggers build of all formats
3. Artifacts uploaded to GitHub release

## License

© 2025 Ryan VanGundy. All rights reserved.

## Contributing

This book is about Windsor CLI. For contributions to the tool itself, visit the [Windsor CLI repository](https://github.com/windsorcli/cli).

For book improvements, please open an issue or pull request.

---

**Happy reading! 📖**
