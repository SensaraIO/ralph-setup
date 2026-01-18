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
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start
```

### Required When Available
- Check MCP availability: `curl -s http://localhost:8081 > /dev/null 2>&1`
- If reachable, use MCP tools (do NOT skip to grep)
- If MCP is unavailable or tools error, document the failure and fallback to grep

### Available Tools
- `automation_take_screenshot` - Full screen capture
- `automation_tap_by_testid` - Tap element
- `automation_find_view_by_testid` - Find element

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
