#!/bin/bash
# Ralph - Create new Expo + Convex project
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
echo "║              Ralph - Full Stack Project                      ║"
echo "║         Expo + Convex + Expo MCP Testing                     ║"
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

if ! command -v npx &> /dev/null; then
  error "npx not found"
  exit 1
fi
success "npx found"

# Create Expo project
log "Creating Expo project: $PROJECT_NAME..."
npx create-expo-app@latest "$PROJECT_NAME" --template "$TEMPLATE"
cd "$PROJECT_NAME"
success "Expo project created"

# Install frontend dependencies
log "Installing frontend dependencies..."
npm install zustand react-hook-form @hookform/resolvers zod
npx expo install expo-secure-store
success "Frontend dependencies installed"

# Install Convex
log "Installing Convex..."
npm install convex
success "Convex installed"

# Install Expo MCP for testing
log "Installing Expo MCP..."
npx expo install expo-mcp --dev
success "Expo MCP installed"

# Initialize git
log "Setting up git..."
git init 2>/dev/null || true
git add .
git commit -m "Initial Expo project" 2>/dev/null || true
success "Git initialized"

# Create project structure
log "Creating project structure..."
mkdir -p app components hooks stores types schemas constants docs convex

# Create types
cat > types/index.ts << 'EOF'
export * from './user';
export * from './auth';
EOF

cat > types/user.ts << 'EOF'
import { Id } from "../convex/_generated/dataModel";

export interface User {
  _id: Id<"users">;
  email: string;
  name: string;
  profileComplete: boolean;
}
EOF

cat > types/auth.ts << 'EOF'
import { User } from './user';

export interface AuthState {
  user: User | null;
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

# Create Convex schema placeholder
cat > convex/schema.ts << 'EOF'
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    passwordHash: v.string(),
    profileComplete: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_email", ["email"]),
});
EOF

# Create Convex auth functions placeholder
cat > convex/auth.ts << 'EOF'
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Placeholder - implement actual auth logic
export const login = mutation({
  args: {
    email: v.string(),
    password: v.string(),
  },
  handler: async (ctx, args) => {
    // TODO: Implement login
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .first();
    
    if (!user) {
      throw new Error("User not found");
    }
    
    // TODO: Verify password hash
    return { userId: user._id };
  },
});

export const register = mutation({
  args: {
    name: v.string(),
    email: v.string(),
    password: v.string(),
  },
  handler: async (ctx, args) => {
    // Check if user exists
    const existing = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .first();
    
    if (existing) {
      throw new Error("User already exists");
    }
    
    // TODO: Hash password properly
    const userId = await ctx.db.insert("users", {
      name: args.name,
      email: args.email,
      passwordHash: args.password, // TODO: Hash this!
      profileComplete: false,
      createdAt: Date.now(),
    });
    
    return { userId };
  },
});

export const getCurrentUser = query({
  args: { userId: v.optional(v.id("users")) },
  handler: async (ctx, args) => {
    if (!args.userId) return null;
    return await ctx.db.get(args.userId);
  },
});
EOF

# Create Convex provider setup
cat > hooks/ConvexProvider.tsx << 'EOF'
import { ConvexProvider as BaseConvexProvider, ConvexReactClient } from "convex/react";
import { ReactNode } from "react";

const convex = new ConvexReactClient(process.env.EXPO_PUBLIC_CONVEX_URL!);

export function ConvexProvider({ children }: { children: ReactNode }) {
  return <BaseConvexProvider client={convex}>{children}</BaseConvexProvider>;
}
EOF

# Create auth store
cat > stores/authStore.ts << 'EOF'
import { create } from 'zustand';
import * as SecureStore from 'expo-secure-store';
import { AuthState, User } from '@/types';

interface AuthStore extends AuthState {
  login: (user: User, userId: string) => Promise<void>;
  logout: () => Promise<void>;
  setLoading: (loading: boolean) => void;
  initialize: () => Promise<void>;
}

const USER_ID_KEY = 'user_id';

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: true,

  login: async (user, userId) => {
    await SecureStore.setItemAsync(USER_ID_KEY, userId);
    set({ user, isAuthenticated: true, isLoading: false });
  },

  logout: async () => {
    await SecureStore.deleteItemAsync(USER_ID_KEY);
    set({ user: null, isAuthenticated: false, isLoading: false });
  },

  setLoading: (loading) => set({ isLoading: loading }),

  initialize: async () => {
    try {
      const userId = await SecureStore.getItemAsync(USER_ID_KEY);
      if (userId) {
        // User ID exists, app will fetch user data
        set({ isAuthenticated: true, isLoading: false });
      } else {
        set({ isAuthenticated: false, isLoading: false });
      }
    } catch {
      set({ isAuthenticated: false, isLoading: false });
    }
  },
}));
EOF

# Create .env.example
cat > .env.example << 'EOF'
# Convex deployment URL
# Get this by running: npx convex dev
EXPO_PUBLIC_CONVEX_URL=
EOF

success "Project structure created"

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
- Backend: Convex in /convex
- Types: Export from /types/index.ts
- Testing: Expo MCP (run with EXPO_UNSTABLE_MCP_SERVER=1)

## Convex Patterns

- Schema: /convex/schema.ts
- Functions: /convex/*.ts (queries, mutations)
- Use ctx.db for database operations
- Use v.* validators for args

---

EOF

# Update gitignore
cat >> .gitignore << 'EOF'

# Ralph
.ralph/.last-branch
.ralph/.edit-log

# Environment
.env.local

# Convex
.convex/
EOF

# Commit
git add .
git commit -m "Add Ralph, Convex, and project structure"

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
echo "  1. Initialize Convex:"
echo "     npx convex dev"
echo "     # Copy the URL to .env.local"
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
echo "  4. Run Ralph:"
echo "     ./ralph.sh"
echo ""
echo "  5. For testing (VERIFY stories):"
echo "     EXPO_UNSTABLE_MCP_SERVER=1 npx expo start"
echo ""
