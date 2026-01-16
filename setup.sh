#!/bin/bash
# Ralph Setup - Add to existing project
# Usage: ./setup.sh [target-path]

set -e

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     Ralph Setup                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

TARGET_DIR=$(cd "$TARGET_DIR" && pwd)
log "Target: $TARGET_DIR"

# Create directories
log "Creating directories..."
mkdir -p "$TARGET_DIR/.ralph"
mkdir -p "$TARGET_DIR/.ralph/test-flows"
mkdir -p "$TARGET_DIR/docs"

# Copy files
log "Copying files..."
cp "$SCRIPT_DIR/.ralph/prompt.md" "$TARGET_DIR/.ralph/"
cp "$SCRIPT_DIR/.ralph/AGENTS.md" "$TARGET_DIR/.ralph/"
cp "$SCRIPT_DIR/.ralph/config.json.template" "$TARGET_DIR/.ralph/config.json"
cp "$SCRIPT_DIR/ralph.sh" "$TARGET_DIR/"
chmod +x "$TARGET_DIR/ralph.sh"

# Copy BRS template if docs empty
if [ -z "$(ls -A "$TARGET_DIR/docs" 2>/dev/null)" ]; then
  cp "$SCRIPT_DIR/docs/BRS-TEMPLATE.md" "$TARGET_DIR/docs/"
fi

# Initialize progress
cat > "$TARGET_DIR/.ralph/progress.txt" << 'EOF'
# Ralph Progress Log

## Codebase Patterns

<!-- Add patterns here -->

---

EOF

# Update gitignore
if [ -f "$TARGET_DIR/.gitignore" ]; then
  if ! grep -q "ralph" "$TARGET_DIR/.gitignore"; then
    echo -e "\n# Ralph\n.ralph/.last-branch" >> "$TARGET_DIR/.gitignore"
  fi
fi

success "Ralph installed!"

echo ""
echo "Next steps:"
echo ""
echo "  1. Configure agent in .ralph/config.json"
echo ""
echo "  2. Install skill for your agent:"
echo "     # Claude Code"
echo "     mkdir -p ~/.claude/skills && cp -r $SCRIPT_DIR/skills/brs-to-ralph ~/.claude/skills/"
echo "     # Cursor"
echo "     mkdir -p ~/.cursor/skills && cp -r $SCRIPT_DIR/skills/brs-to-ralph ~/.cursor/skills/"
echo ""
echo "  3. Add BRS and convert:"
echo "     cp /path/to/brs.md docs/"
echo "     claude  # or cursor"
echo "     > Load brs-to-ralph skill, convert docs/brs.md"
echo ""
echo "  4. Run: ./ralph.sh"
echo ""
