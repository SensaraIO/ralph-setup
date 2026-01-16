#!/bin/bash
# Ralph-CC Setup Script
# Adds Ralph-CC to an existing project
# Usage: ./setup.sh [target-project-path]

set -e

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH-CC]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   Ralph-CC Setup                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Resolve target directory
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)
log "Target: $TARGET_DIR"

# Check if git repo
if [ ! -d "$TARGET_DIR/.git" ]; then
  warn "Not a git repository. Ralph-CC requires git."
  read -p "Initialize git? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$TARGET_DIR" && git init
  else
    exit 1
  fi
fi

# Create .ralph directory
log "Creating .ralph directory..."
mkdir -p "$TARGET_DIR/.ralph"
mkdir -p "$TARGET_DIR/.ralph/test-flows"
mkdir -p "$TARGET_DIR/docs"

# Copy prompt files
log "Copying configuration files..."
cp "$SCRIPT_DIR/.ralph/prompt.md" "$TARGET_DIR/.ralph/"
cp "$SCRIPT_DIR/.ralph/AGENTS.md" "$TARGET_DIR/.ralph/"

# Initialize progress file
cat > "$TARGET_DIR/.ralph/progress.txt" << 'EOF'
# Ralph-CC Progress Log

## Codebase Patterns

<!-- Add patterns here as you discover them -->
<!-- These help future iterations understand your project -->

---

<!-- Iteration logs below - append only -->
EOF

# Copy main script
log "Copying ralph-cc.sh..."
cp "$SCRIPT_DIR/ralph-cc.sh" "$TARGET_DIR/"
chmod +x "$TARGET_DIR/ralph-cc.sh"

# Copy docs template if docs dir is empty
if [ -z "$(ls -A "$TARGET_DIR/docs" 2>/dev/null)" ]; then
  cp "$SCRIPT_DIR/docs/BRS-TEMPLATE.md" "$TARGET_DIR/docs/"
fi

# Update .gitignore
log "Updating .gitignore..."
if [ -f "$TARGET_DIR/.gitignore" ]; then
  if ! grep -q "ralph-cc" "$TARGET_DIR/.gitignore"; then
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# Ralph-CC" >> "$TARGET_DIR/.gitignore"
    echo ".ralph/.last-branch" >> "$TARGET_DIR/.gitignore"
  fi
else
  cat > "$TARGET_DIR/.gitignore" << 'EOF'
# Ralph-CC
.ralph/.last-branch
EOF
fi

success "Ralph-CC installed!"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SETUP COMPLETE                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "  1. Install the brs-to-ralph skill:"
echo "     mkdir -p ~/.claude/skills"
echo "     cp -r $SCRIPT_DIR/skills/brs-to-ralph ~/.claude/skills/"
echo ""
echo "  2. Add your BRS document to docs/"
echo ""
echo "  3. Convert BRS in Claude Code:"
echo "     cd $TARGET_DIR"
echo "     claude"
echo "     > Load brs-to-ralph skill, convert docs/your-brs.md"
echo ""
echo "  4. Run Ralph-CC:"
echo "     ./ralph-cc.sh"
echo ""
