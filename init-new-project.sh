#!/bin/bash
# Ralph-CC New Project Initializer
# Creates a new Expo project with Ralph-CC configured
# Usage: ./init-new-project.sh <project-name> [template]
#
# Examples:
#   ./init-new-project.sh my-app
#   ./init-new-project.sh my-app blank-typescript

set -e

PROJECT_NAME="${1:-my-app}"
TEMPLATE="${2:-tabs}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH-CC]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           Ralph-CC New Project Initializer                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
log "Checking prerequisites..."

if ! command -v node &> /dev/null; then
  error "Node.js not found. Please install Node.js 18+ first."
  exit 1
fi
success "Node.js: $(node --version)"

if ! command -v npx &> /dev/null; then
  error "npx not found. Please install npm."
  exit 1
fi
success "npx found"

if ! command -v jq &> /dev/null; then
  error "jq not found. Install: brew install jq"
  exit 1
fi
success "jq found"

if ! command -v claude &> /dev/null; then
  warn "Claude Code CLI not found - you'll need it to run Ralph-CC"
fi

if ! command -v maestro &> /dev/null; then
  warn "Maestro not found - install with: brew install maestro"
fi

# Create Expo project
log "Creating Expo project: $PROJECT_NAME (template: $TEMPLATE)..."
npx create-expo-app@latest "$PROJECT_NAME" --template "$TEMPLATE"

cd "$PROJECT_NAME"
success "Expo project created"

# Install recommended dependencies
log "Installing dependencies..."
npm install zustand react-hook-form @hookform/resolvers zod @tanstack/react-query axios
npx expo install expo-secure-store
success "Dependencies installed"

# Initialize git (may already be initialized)
log "Setting up git..."
git init 2>/dev/null || true
git add .
git commit -m "Initial Expo project setup" 2>/dev/null || true
success "Git initialized"

# Create project structure
log "Creating project structure..."
mkdir -p app
mkdir -p components
mkdir -p hooks
mkdir -p stores
mkdir -p types
mkdir -p schemas
mkdir -p api
mkdir -p constants
mkdir -p docs

# Create placeholder files
cat > types/index.ts << 'EOF'
// Export all types from here
export * from './user';
export * from './auth';
EOF

cat > types/user.ts << 'EOF'
export interface User {
  id: string;
  email: string;
  name: string;
  profileComplete: boolean;
}
EOF

cat > types/auth.ts << 'EOF'
import { User } from './user';

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface RegisterInput {
  name: string;
  email: string;
  password: string;
}
EOF

cat > constants/api.ts << 'EOF'
export const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'https://api.example.com';
EOF

success "Project structure created"

# Install Ralph-CC
log "Installing Ralph-CC..."
mkdir -p .ralph
mkdir -p .ralph/test-flows

cp "$SCRIPT_DIR/.ralph/prompt.md" .ralph/
cp "$SCRIPT_DIR/.ralph/AGENTS.md" .ralph/
cp "$SCRIPT_DIR/ralph-cc.sh" ./
chmod +x ralph-cc.sh

# Initialize progress file
cat > .ralph/progress.txt << 'EOF'
# Ralph-CC Progress Log

## Codebase Patterns

- Navigation: expo-router in /app directory
- State: Zustand stores in /stores
- Forms: react-hook-form with zod in /schemas
- API: @tanstack/react-query hooks in /hooks
- Types: All types exported from /types/index.ts

---

EOF

# Copy BRS template
cp "$SCRIPT_DIR/docs/BRS-TEMPLATE.md" docs/

success "Ralph-CC installed"

# Update .gitignore
cat >> .gitignore << 'EOF'

# Ralph-CC
.ralph/.last-branch
EOF

# Commit Ralph-CC setup
git add .
git commit -m "Add Ralph-CC and project structure"

success "Project ready!"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SETUP COMPLETE                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Project created at: $(pwd)"
echo ""
echo "Next steps:"
echo ""
echo "  1. Install the brs-to-ralph skill:"
echo "     mkdir -p ~/.claude/skills"
echo "     cp -r $SCRIPT_DIR/skills/brs-to-ralph ~/.claude/skills/"
echo ""
echo "  2. Add your BRS document:"
echo "     cp /path/to/your-brs.md docs/"
echo ""
echo "  3. Convert BRS in Claude Code:"
echo "     cd $(pwd)"
echo "     claude"
echo "     > Load brs-to-ralph skill, convert docs/your-brs.md"
echo ""
echo "  4. Run Ralph-CC:"
echo "     ./ralph-cc.sh"
echo ""
