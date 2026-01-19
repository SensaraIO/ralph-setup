# Ralph Quick Reference

## Stack
- **Frontend:** Expo + React Native
- **Backend:** Convex
- **Testing:** Expo MCP

## Commands

```bash
# New project
~/tools/ralph/init-project.sh my-app

# Existing project
~/tools/ralph/setup.sh .

# Initialize Convex
npx convex dev

# Install skill
mkdir -p ~/.claude/skills
cp -r ~/tools/ralph/skills/brs-to-ralph ~/.claude/skills/

# Convert BRS
claude
> Load brs-to-ralph skill, convert docs/my-brs.md

# Run Ralph
./ralph.sh
./ralph.sh --agent cursor

# For testing (VERIFY stories)
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start

# Progress
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'
```

## Agents

| Agent | Config |
|-------|--------|
| Claude Code | `"agent": "claude"` |
| Cursor | `"agent": "cursor"` |
| Codex | `"agent": "codex"` |

## Story Layers

| Layer | What |
|-------|------|
| `backend` | Convex only |
| `frontend` | Expo only |
| `fullstack` | Both |

## Convex Quick

```typescript
// Schema
defineTable({ name: v.string() }).index("by_name", ["name"])

// Query
export const get = query({ args: { id: v.id("table") }, handler: ... })

// Mutation
export const create = mutation({ args: { name: v.string() }, handler: ... })
```

## Expo MCP Tools

| Tool | Use |
|------|-----|
| `automation_take_screenshot` | Capture screen (or view by testID) |
| `automation_tap` | Tap element by testID |
| `automation_find_view` | Verify element exists by testID |

## Cursor CLI

```bash
# MCP discovery
agent mcp list
agent mcp list-tools expo-mcp
agent mcp list-tools Convex

# Start Expo with log capture
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start 2>&1 | tee .ralph/expo.log

# Check logs for errors
grep -i "error\|warn" .ralph/expo.log | tail -50
```

## Files

| File | Purpose |
|------|---------|
| `.ralph/prd.json` | Stories |
| `.ralph/progress.txt` | Learnings |
| `.ralph/testid-contracts.json` | TestIDs |
| `convex/schema.ts` | DB schema |
| `convex/*.ts` | Functions |
| `.env.example` | Env vars |
