#!/bin/bash
# Ralph - Create new Expo project with Ralph configured
# Usage: ./init-project.sh <project-name> [expo-template]

set -e

PROJECT_NAME="${1:-my-app}"
TEMPLATE="${2:-tabs}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[RALPH]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Ralph - New Project                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
log "Checking prerequisites..."

if ! command -v node &> /dev/null; then
  error "Node.js not found"
  exit 1
fi
success "Node.js: $(node --version)"

if ! command -v jq &> /dev/null; then
  error "jq not found. Install: brew install jq"
  exit 1
fi
success "jq found"

# Create Expo project
log "Creating Expo project: $PROJECT_NAME..."
npx create-expo-app@latest "$PROJECT_NAME" --template "$TEMPLATE"
cd "$PROJECT_NAME"
success "Expo project created"

# Install dependencies
log "Installing dependencies..."
npm install zustand react-hook-form @hookform/resolvers zod @tanstack/react-query axios
npx expo install expo-secure-store
success "Dependencies installed"

# Initialize git
log "Setting up git..."
git init 2>/dev/null || true
git add .
git commit -m "Initial Expo project" 2>/dev/null || true
success "Git initialized"

# Create structure
log "Creating project structure..."
mkdir -p app components hooks stores types schemas api constants docs

cat > types/index.ts << 'EOF'
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

success "Structure created"

# Install Ralph
log "Installing Ralph..."
mkdir -p .ralph .ralph/test-flows

cp "$SCRIPT_DIR/.ralph/prompt.md" .ralph/
cp "$SCRIPT_DIR/.ralph/AGENTS.md" .ralph/
cp "$SCRIPT_DIR/.ralph/config.json.template" .ralph/config.json
cp "$SCRIPT_DIR/ralph.sh" ./
cp "$SCRIPT_DIR/docs/BRS-TEMPLATE.md" docs/
chmod +x ralph.sh

cat > .ralph/progress.txt << 'EOF'
# Ralph Progress Log

## Codebase Patterns

- Navigation: expo-router in /app
- State: Zustand in /stores
- Forms: react-hook-form + zod in /schemas
- API: @tanstack/react-query in /hooks
- Types: Export from /types/index.ts

---

EOF

# Update gitignore
echo -e "\n# Ralph\n.ralph/.last-branch" >> .gitignore

# Commit
git add .
git commit -m "Add Ralph and project structure"

success "Project ready!"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SETUP COMPLETE                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Project: $(pwd)"
echo ""
echo "Next steps:"
echo ""
echo "  1. Configure agent in .ralph/config.json"
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
