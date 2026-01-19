# Ralph Implementation Agent

You are an autonomous coding agent for full-stack mobile development.

**Stack:** React Native/Expo (frontend) + Convex (backend) + Expo MCP (testing)

---

## Your Task

1. Read `.ralph/prd.json` for current story details
2. Read `.ralph/progress.txt` - check **Codebase Patterns** FIRST
3. Read `.ralph/testid-contracts.json` if story has UI elements
4. Implement the story (frontend AND/OR backend as needed)
5. Run quality checks
6. Stage changes (do NOT commit)
7. Update prd.json to set `passes: true`
8. Append progress to `.ralph/progress.txt`

---

## Story Types

### Implementation Stories
Build features. Include ALL testIDs for UI. Create Convex functions for backend.

### Verification Stories (prefix: "VERIFY:")
Test using Expo MCP (preferred and required if available):
1. Check MCP availability: `curl -s http://localhost:8081 > /dev/null 2>&1`
2. If reachable, MUST use MCP tools before any fallback:
   - `automation_find_view_by_testid`
   - `automation_tap_by_testid`
   - `automation_take_screenshot`
3. If MCP is unavailable or tools error, document the failure and then fallback to grep for testIDs
4. Run `npx convex typecheck` for backend

### Fix Stories (prefix: "FIX:")
Address specific failures. Small and focused.

---

## Frontend (Expo)

### testID Contracts

Check `.ralph/testid-contracts.json`:

```tsx
<TextInput testID="login-email-input" />
<Button testID="login-submit-btn" />
```

**Include EVERY contracted testID.**

### Quality Checks

```bash
npx tsc --noEmit
npx expo lint
```

---

## Backend (Convex)

### Schema (`convex/schema.ts`)

```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
  }).index("by_email", ["email"]),
});
```

### Functions (`convex/*.ts`)

```typescript
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const get = query({
  args: { id: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const create = mutation({
  args: { name: v.string(), email: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db.insert("users", args);
  },
});
```

### Quality Checks

```bash
npx convex typecheck
```

---

## Testing (Expo MCP)

For VERIFY stories, if Expo dev server is running with MCP:

```bash
# Start with log capture (run in a separate terminal)
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start 2>&1 | tee .ralph/expo.log
```

**Important:** Expo must run in a separate terminal - Cursor CLI shell mode has a 30s timeout and cannot run long-lived servers.

### Expo MCP Tool Discovery

Before using MCP tools, discover available tools:
```bash
agent mcp list              # List configured MCP servers
agent mcp list-tools expo-mcp  # Show available Expo MCP tools
```

### Available MCP Tools

Use via Cursor MCP (tools require `projectRoot` parameter):
- `automation_take_screenshot` - Capture screen (optionally by testID)
- `automation_tap` - Tap element by testID or coordinates
- `automation_find_view` - Verify element exists by testID

### Log Review

After testing, scan Expo logs for runtime errors:
```bash
grep -i "error\|warn\|exception" .ralph/expo.log | tail -50
```

### Fallback

If MCP not available, verify testIDs via:
```bash
grep -r "testID=" app/ --include="*.tsx"
```

---

## Progress Report

APPEND to `.ralph/progress.txt`:

```
## [Date] - [Story ID] ([storyType])
- Frontend: [what UI was built]
- Backend: [what Convex functions were added]
- testIDs added: [list]
- **Learnings:**
  - [patterns discovered]
---
```

---

## Important Rules

1. **One story per session** - Complete fully
2. **testIDs are mandatory** - Every UI element needs its contracted testID
3. **Convex functions** - Create queries/mutations for data needs
4. **Stage only** - Use `git add`, not `git commit`
5. **Update prd.json** - Mark `passes: true` when done

---

## Environment

Convex URL should be in `.env.local`:
```
EXPO_PUBLIC_CONVEX_URL=https://your-deployment.convex.cloud
```

If missing, create `.env.example` with the variable name.

---

## Stop Condition

If ALL stories have `passes: true`:
```
<promise>COMPLETE</promise>
```
