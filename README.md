# Ralph

Autonomous AI agent loop for full-stack mobile app development using any CLI-based AI coding agent.

Ralph takes a BRS (Business Requirements Specification) document and autonomously implements it story-by-story with:
- **React Native/Expo** frontend
- **Convex** backend (database + functions)
- **Expo MCP** for automated testing

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

---

## Supported Agents

| Agent | Command | Status |
|-------|---------|--------|
| Claude Code | `claude` | ✅ Tested |
| Cursor CLI | `cursor` / `agent` | ✅ Supported |
| Codex CLI | `codex` | ✅ Supported |
| Aider | `aider` | ✅ Supported |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React Native + Expo |
| Backend | Convex (database + functions) |
| Testing | Expo MCP (automation) |
| State | Zustand |
| Forms | react-hook-form + zod |
| API | Convex client hooks |

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           RALPH FLOW                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your BRS Document                                                     │
│        │                                                                │
│        ▼                                                                │
│   ┌─────────────────┐     ┌─────────────────────────────────────────┐  │
│   │ brs-to-ralph    │────▶│ prd.json + testid-contracts.json        │  │
│   │ skill           │     │ + convex schema + test flows            │  │
│   └─────────────────┘     └──────────────────┬──────────────────────┘  │
│                                              │                          │
│                                              ▼                          │
│   ┌──────────────────────────────────────────────────────────────────┐ │
│   │                        ralph.sh                                   │ │
│   │                                                                   │ │
│   │   FOR each story:                                                 │ │
│   │       │                                                           │ │
│   │       ▼                                                           │ │
│   │   ┌─────────────────────────────────────────────────────────┐    │ │
│   │   │ Spawn FRESH agent instance                               │    │ │
│   │   │   • Implements frontend OR backend for story             │    │ │
│   │   │   • Runs quality checks                                  │    │ │
│   │   │   • Updates prd.json (passes: true)                      │    │ │
│   │   │   • Exits (context cleared)                              │    │ │
│   │   └─────────────────────────────────────────────────────────┘    │ │
│   │       │                                                           │ │
│   │       ▼                                                           │ │
│   │   Next story...                                                   │ │
│   └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│   VERIFY stories use Expo MCP for automated UI testing                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

```bash
# Required
brew install jq

# Convex CLI
npm install -g convex

# Install your preferred agent CLI:
# Claude Code: https://docs.anthropic.com/claude-code
# Cursor: curl https://cursor.com/install -fsS | bash
# Codex: npm install -g @openai/codex
```

---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/ralph.git ~/tools/ralph
```

### 2. Create a new project

```bash
~/tools/ralph/init-project.sh my-app
cd my-app
```

This creates:
- Expo project with all dependencies
- Convex backend initialized
- Expo MCP for testing
- `.env.example` with required variables

### 3. Configure Convex

```bash
# Login to Convex
npx convex login

# Initialize (creates deployment)
npx convex dev
```

### 4. Configure your agent

Edit `.ralph/config.json`:
```json
{
  "agent": "claude"
}
```

### 5. Add your BRS and convert

```bash
cp /path/to/your-brs.md docs/

# In your agent:
> Load the brs-to-ralph skill, convert docs/your-brs.md
```

### 6. Run Ralph

```bash
./ralph.sh
```

---

## Testing with Expo MCP

Ralph uses Expo MCP for automated testing instead of Maestro.

### For VERIFY Stories

1. **Start the dev server with MCP:**
   ```bash
   EXPO_UNSTABLE_MCP_SERVER=1 npx expo start
   ```

2. **In another terminal, run the agent:**
   ```bash
   claude  # or cursor
   ```

3. **The agent uses MCP tools for testing:**
   - `automation_take_screenshot` - Capture screen state
   - `automation_tap_by_testid` - Tap elements by testID
   - `automation_find_view_by_testid` - Find and analyze views

### Expo MCP Tools

| Tool | Description |
|------|-------------|
| `automation_take_screenshot` | Full device screenshot |
| `automation_tap_by_testid` | Tap view by testID |
| `automation_find_view_by_testid` | Find view properties |
| `automation_take_screenshot_by_testid` | Screenshot specific view |
| `learn` | Learn Expo how-to |
| `add_library` | Install packages |

---

## Convex Backend

Ralph generates Convex schema and functions alongside frontend code.

### Directory Structure

```
my-app/
├── convex/
│   ├── schema.ts          # Database schema
│   ├── auth.ts            # Auth functions
│   ├── users.ts           # User queries/mutations
│   └── _generated/        # Auto-generated types
├── app/                   # Expo screens
├── hooks/
│   └── useConvex*.ts      # Convex query hooks
└── .env.local             # CONVEX_URL
```

### Schema Example

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    profileComplete: v.boolean(),
  }).index("by_email", ["email"]),
});
```

### Function Example

```typescript
// convex/users.ts
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const get = query({
  args: { id: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});
```

---

## Story Types

| Type | Prefix | Purpose |
|------|--------|---------|
| `implementation` | - | Build frontend/backend |
| `verification` | VERIFY: | Run Expo MCP tests |
| `fix` | FIX: | Address failures |

### Phase Structure

```
PHASE-01: Foundation
  US-001: Convex schema
  US-002: Auth functions  
  US-003: Frontend types/stores
  US-004: VERIFY: Schema deploys

PHASE-02: Auth Screens
  US-005: Login mutations
  US-006: Login screen + testIDs
  US-007: Register mutations
  US-008: Register screen + testIDs
  US-009: VERIFY: Auth flow (Expo MCP)
```

---

## Environment Variables

```bash
# .env.example
EXPO_PUBLIC_CONVEX_URL=
```

Run `npx convex dev` to get your deployment URL, then add to `.env.local`.

---

## Commands Reference

```bash
# New project
~/tools/ralph/init-project.sh my-app

# Add to existing
~/tools/ralph/setup.sh .

# Run Ralph
./ralph.sh
./ralph.sh --agent cursor
./ralph.sh --max 100

# Convex dev (runs in background)
npx convex dev

# Start dev server for testing
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start

# Check progress
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'
```

---

## Troubleshooting

### "Convex schema errors"
Run `npx convex dev` to see detailed errors.

### "Expo MCP not connecting"
Ensure dev server is running with `EXPO_UNSTABLE_MCP_SERVER=1` flag.
Restart your agent after starting/stopping the dev server.

### "testID not found"
Check the element has `testID` prop and app is on correct screen.

### "Context exceeded"
Story too big. Split in `.ralph/prd.json`.

---

## License

MIT
