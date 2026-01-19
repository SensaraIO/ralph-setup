# Ralph Agent Patterns

## Tech Stack

- **Frontend:** React Native + Expo
- **Backend:** Convex (database + serverless functions)
- **Testing:** Expo MCP (automation)
- **State:** Zustand
- **Forms:** react-hook-form + zod

---

## State Persistence

Ralph spawns fresh agent instances per story. State persists via:
- `.ralph/prd.json` - Story status
- `.ralph/progress.txt` - Patterns and learnings
- `.ralph/testid-contracts.json` - Required testIDs
- Git staged files - Actual code
- Convex - Database (persistent backend)

---

## Convex Patterns

### Schema Changes
```bash
# After changing convex/schema.ts
npx convex dev  # Pushes schema
```

### Query Pattern
```typescript
export const list = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query("items").collect();
  },
});
```

### Mutation Pattern
```typescript
export const create = mutation({
  args: { name: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db.insert("items", { name: args.name });
  },
});
```

### Using in React
```typescript
import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

const items = useQuery(api.items.list);
const createItem = useMutation(api.items.create);
```

---

## Expo MCP Testing

### Start Dev Server with MCP
```bash
# With log capture (run in a separate terminal)
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start 2>&1 | tee .ralph/expo.log
```

**Important:** Expo must run in a separate terminal - Cursor CLI shell mode has a 30s timeout.

### MCP Discovery (Cursor CLI)
```bash
agent mcp list              # List configured MCP servers
agent mcp list-tools expo-mcp  # Show available Expo tools
```

### Required When Available
- Check MCP availability: `curl -s http://localhost:8081 > /dev/null 2>&1`
- If reachable, use MCP tools via Cursor (do NOT skip to grep)
- If MCP is unavailable or tools error, document the failure and fallback to grep

### Available Tools (via expo-mcp server)
- `automation_take_screenshot` - Full screen capture (optionally by testID)
- `automation_tap` - Tap element by testID or coordinates
- `automation_find_view` - Find element by testID

### Console Log Review
```bash
grep -i "error\|warn\|exception" .ralph/expo.log | tail -50
```

---

## Story Dependencies

```
Schema → Functions → Types → Stores → Hooks → Screens → VERIFY
```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Missing testID | Check contract |
| Convex type error | Run `npx convex typecheck` |
| Schema not updating | Run `npx convex dev` |
| MCP not working | Restart dev server with flag |
| Context exceeded | Split story |
