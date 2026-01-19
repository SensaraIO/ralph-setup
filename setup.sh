#!/bin/bash
# Ralph Setup - Add to existing Expo project
# Usage: ./setup.sh [target-path]

set -e

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     Ralph Setup                              ║"
echo "║           Expo + Convex + Expo MCP                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

TARGET_DIR=$(cd "$TARGET_DIR" && pwd)
log "Target: $TARGET_DIR"

cd "$TARGET_DIR"

# Install Convex if not present
if [ ! -d "convex" ]; then
  log "Installing Convex..."
  npm install convex
  mkdir -p convex
  
  # Create basic schema
  cat > convex/schema.ts << 'EOF'
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Add your tables here
});
EOF
  success "Convex installed"
else
  success "Convex already present"
fi

# Install Expo MCP if not present
if ! grep -q "expo-mcp" package.json 2>/dev/null; then
  log "Installing Expo MCP..."
  npx expo install expo-mcp --dev
  success "Expo MCP installed"
else
  success "Expo MCP already present"
fi

# Create directories
log "Creating directories..."
mkdir -p .ralph .ralph/test-flows docs

# Copy files
log "Copying Ralph files..."
cp "$SCRIPT_DIR/.ralph/prompt.md" .ralph/
cp "$SCRIPT_DIR/.ralph/AGENTS.md" .ralph/
cp "$SCRIPT_DIR/.ralph/config.json.template" .ralph/config.json
cp "$SCRIPT_DIR/ralph.sh" ./
chmod +x ralph.sh

# Copy Cursor CLI configuration
log "Setting up Cursor CLI support..."
mkdir -p .cursor/agents .cursor/hooks
cp "$SCRIPT_DIR/cursor/agents/"*.md .cursor/agents/ 2>/dev/null || true
cp "$SCRIPT_DIR/cursor/hooks/"* .cursor/hooks/ 2>/dev/null || true
cp "$SCRIPT_DIR/cursor/cli.json" .cursor/ 2>/dev/null || true
cp "$SCRIPT_DIR/cursor/mcp.json" .cursor/ 2>/dev/null || true
chmod +x .cursor/hooks/*.sh 2>/dev/null || true
success "Cursor CLI configured"

# Copy BRS template if docs empty
if [ -z "$(ls -A docs 2>/dev/null)" ]; then
  cp "$SCRIPT_DIR/docs/BRS-TEMPLATE.md" docs/
fi

# Initialize progress
cat > .ralph/progress.txt << 'EOF'
# Ralph Progress Log

## Codebase Patterns

- Navigation: expo-router in /app
- State: Zustand in /stores
- Forms: react-hook-form + zod
- Backend: Convex in /convex
- Testing: Expo MCP

---

EOF

# Create .env.example if not exists
if [ ! -f ".env.example" ]; then
  cat > .env.example << 'EOF'
# Convex deployment URL
EXPO_PUBLIC_CONVEX_URL=
EOF
fi

# Update gitignore
if [ -f ".gitignore" ]; then
  if ! grep -q "ralph" .gitignore; then
    echo -e "\n# Ralph\n.ralph/.last-branch\n.ralph/.edit-log\n\n# Environment\n.env.local" >> .gitignore
  fi
fi

success "Ralph installed!"

echo ""
echo "Next steps:"
echo ""
echo "  1. Initialize Convex (if new):"
echo "     npx convex dev"
echo ""
echo "  2. Install skill:"
echo "     mkdir -p ~/.claude/skills"
echo "     cp -r $SCRIPT_DIR/skills/brs-to-ralph ~/.claude/skills/"
echo ""
echo "  3. Add BRS and convert:"
echo "     cp /path/to/brs.md docs/"
echo "     claude"
echo "     > Load brs-to-ralph skill, convert docs/brs.md"
echo ""
echo "  4. Run: ./ralph.sh"
echo ""
echo "  5. For testing:"
echo "     EXPO_UNSTABLE_MCP_SERVER=1 npx expo start"
echo ""
