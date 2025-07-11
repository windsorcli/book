#!/bin/bash

# Build script for diagrams
# Supports both SVG and TikZ (.tex) files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$PROJECT_ROOT/diagrams/src"
OUTPUT_DIR="$PROJECT_ROOT/diagrams/generated"

echo -e "${BLUE}🎨 Building diagrams...${NC}"
echo -e "${BLUE}📁 Source directory: $SRC_DIR${NC}"
echo -e "${BLUE}📁 Output directory: $OUTPUT_DIR${NC}"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${RED}❌ Source directory not found: $SRC_DIR${NC}"
    exit 1
fi

# Function to convert SVG to PNG
convert_svg_to_png() {
    local svg_file="$1"
    local basename=$(basename "$svg_file" .svg)
    local png_file="$OUTPUT_DIR/${basename}.png"

    echo -e "  ${YELLOW}🔄 Processing: ${basename}.svg → ${basename}.png${NC}"

    # Convert SVG to PNG using rsvg-convert (part of librsvg)
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 800 -h 600 "$svg_file" -o "$png_file"
    elif command -v inkscape >/dev/null 2>&1; then
        inkscape --export-type=png --export-width=800 --export-height=600 "$svg_file" --export-filename="$png_file"
    else
        echo -e "${RED}❌ Neither rsvg-convert nor inkscape found. Please install librsvg or inkscape.${NC}"
        exit 1
    fi

    echo -e "  ${GREEN}✅ Generated: ${basename}.png${NC}"
}

# Function to convert TikZ to PNG
convert_tikz_to_png() {
    local tex_file="$1"
    local basename=$(basename "$tex_file" .tex)
    local png_file="$OUTPUT_DIR/${basename}.png"

    echo -e "  ${YELLOW}🔄 Processing: ${basename}.tex → ${basename}.png${NC}"

    # Check if pdflatex is available
    if ! command -v pdflatex >/dev/null 2>&1; then
        echo -e "${RED}❌ pdflatex not found. Please install a LaTeX distribution (e.g., MacTeX, TeX Live).${NC}"
        exit 1
    fi

    # Create temporary directory for LaTeX compilation
    local temp_dir=$(mktemp -d)
    local temp_tex="$temp_dir/${basename}.tex"
    local temp_pdf="$temp_dir/${basename}.pdf"

    # Copy tex file to temp directory
    cp "$tex_file" "$temp_tex"

    # Compile LaTeX to PDF
    cd "$temp_dir"
    pdflatex -interaction=nonstopmode "$temp_tex" > /dev/null 2>&1

    if [ ! -f "$temp_pdf" ]; then
        echo -e "${RED}❌ LaTeX compilation failed for ${basename}.tex${NC}"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Convert PDF to PNG
    if command -v convert >/dev/null 2>&1; then
        # Using ImageMagick
        convert -density 300 "$temp_pdf" -quality 90 "$png_file"
    elif command -v gs >/dev/null 2>&1; then
        # Using Ghostscript
        gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r300 -sOutputFile="$png_file" "$temp_pdf"
    else
        echo -e "${RED}❌ Neither ImageMagick (convert) nor Ghostscript (gs) found. Please install one of them.${NC}"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Clean up
    rm -rf "$temp_dir"
    cd "$PROJECT_ROOT"

    echo -e "  ${GREEN}✅ Generated: ${basename}.png${NC}"
}

# Process all files
svg_files=$(find "$SRC_DIR" -name "*.svg" 2>/dev/null || true)
tex_files=$(find "$SRC_DIR" -name "*.tex" 2>/dev/null || true)

if [ -n "$svg_files" ]; then
    echo -e "${BLUE}📊 Found SVG files, converting to PNG...${NC}"
    while IFS= read -r svg_file; do
        convert_svg_to_png "$svg_file"
    done <<< "$svg_files"
fi

if [ -n "$tex_files" ]; then
    echo -e "${BLUE}📊 Found TikZ files, converting to PNG...${NC}"
    while IFS= read -r tex_file; do
        convert_tikz_to_png "$tex_file"
    done <<< "$tex_files"
fi

if [ -z "$svg_files" ] && [ -z "$tex_files" ]; then
    echo -e "${YELLOW}⚠️  No SVG or TikZ files found in $SRC_DIR${NC}"
    exit 0
fi

echo -e "${GREEN}🎉 All diagrams generated successfully!${NC}"
echo -e "${BLUE}📝 To use diagrams in Typst, reference them like:${NC}"
echo -e "${BLUE}   #figure(image(\"diagrams/generated/your-diagram.png\"), caption: [Your caption])${NC}"
