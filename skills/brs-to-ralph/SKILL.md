---
name: brs-to-ralph
description: "Convert BRS to prd.json for Ralph full-stack development. Generates stories for Expo frontend, Convex backend, testID contracts, and Expo MCP test flows."
---

# BRS to Ralph Converter

Converts BRS documents to Ralph format for full-stack mobile development.

**Stack:** Expo (frontend) + Convex (backend) + Expo MCP (testing)

---

## Output Files

1. `.ralph/prd.json` - User stories (frontend + backend)
2. `.ralph/testid-contracts.json` - Required testIDs
3. `convex/schema.ts` - Database schema (if not exists)

---

## prd.json Format

```json
{
  "project": "AppName",
  "branchName": "ralph/feature",
  "phases": [
    { "id": "PHASE-01", "name": "Foundation" }
  ],
  "userStories": [
    {
      "id": "US-001",
      "phaseId": "PHASE-01",
      "storyType": "implementation",
      "layer": "backend",
      "title": "Create user schema and functions",
      "acceptanceCriteria": [
        "users table in convex/schema.ts",
        "create mutation in convex/users.ts",
        "get query in convex/users.ts",
        "npx convex typecheck passes"
      ],
      "priority": 1,
      "passes": false
    }
  ]
}
```

---

## Story Layers

Stories should specify their layer:

| Layer | Description |
|-------|-------------|
| `backend` | Convex schema/functions only |
| `frontend` | Expo UI components only |
| `fullstack` | Both frontend and backend |

---

## Phase Structure

```
PHASE-01: Foundation
  US-001: Convex schema (backend)
  US-002: Core Convex functions (backend)
  US-003: Frontend types/stores
  US-004: VERIFY: Schema deploys

PHASE-02: Auth
  US-005: Auth Convex functions (backend)
  US-006: Login screen + testIDs (frontend)
  US-007: Register screen + testIDs (frontend)
  US-008: VERIFY: Auth flow (Expo MCP)

PHASE-03: Features
  US-009: Feature functions (backend)
  US-010: Feature screen (frontend)
  ...
  US-XXX: VERIFY: Feature tests
```

---

## Convex Schema Generation

For data entities in the BRS, generate schema:

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    passwordHash: v.string(),
    profileComplete: v.boolean(),
    createdAt: v.number(),
  }).index("by_email", ["email"]),
  
  // Add tables for each entity
});
```

---

## Convex Function Stories

Backend stories create queries/mutations:

```json
{
  "id": "US-002",
  "layer": "backend",
  "title": "Create user CRUD functions",
  "acceptanceCriteria": [
    "convex/users.ts with create mutation",
    "convex/users.ts with get query",
    "convex/users.ts with update mutation",
    "npx convex typecheck passes"
  ]
}
```

---

## testID Contract Format

```json
{
  "contracts": [
    {
      "storyId": "US-006",
      "screen": "LoginScreen",
      "testIds": [
        { "id": "login-email-input", "element": "TextInput" },
        { "id": "login-password-input", "element": "TextInput" },
        { "id": "login-submit-btn", "element": "Button" },
        { "id": "login-error-text", "element": "Text" }
      ]
    }
  ]
}
```

---

## VERIFY Stories (Expo MCP)

VERIFY stories use Expo MCP for testing:

```json
{
  "id": "US-008",
  "storyType": "verification",
  "title": "VERIFY: Auth flow",
  "acceptanceCriteria": [
    "All auth testIDs present in codebase",
    "Expo MCP: Navigate to login screen",
    "Expo MCP: automation_find_view_by_testid('login-email-input')",
    "Expo MCP: automation_tap_by_testid('login-submit-btn')",
    "Expo MCP: automation_take_screenshot for verification",
    "npx convex typecheck passes"
  ]
}
```

---

## Story Sizing

**Each story must complete in ONE context window.**

Right-sized:
- One Convex table + basic CRUD
- One screen layout with testIDs
- One form with validation

Too big (split):
- "Build authentication" → Schema, functions, login screen, register screen
- "Create dashboard" → Data functions, layout, widgets

---

## Acceptance Criteria Rules

**Backend stories:**
```
"[table] in convex/schema.ts",
"[function] in convex/[file].ts",
"npx convex typecheck passes"
```

**Frontend stories:**
```
"[Element] with testID='[screen]-[element]-[purpose]'",
"TypeScript compiles",
"Lint passes"
```

**VERIFY stories:**
```
"All [phase] testIDs present",
"Expo MCP: [test action]",
"npx convex typecheck passes"
```

---

## Conversion Checklist

- [ ] Identify data entities → Convex schema
- [ ] Create backend stories for each entity's functions
- [ ] Create frontend stories for each screen
- [ ] Backend stories come BEFORE frontend that depends on them
- [ ] Each phase ends with VERIFY
- [ ] testID contracts for all UI screens
- [ ] All stories have `passes: false`
