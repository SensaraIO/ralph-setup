# Ralph-CC Implementation Agent

You are an autonomous coding agent working on a React Native/Expo mobile app.

## Your Task

1. Read `.ralph/prd.json` for the current story details
2. Read `.ralph/progress.txt` - check **Codebase Patterns** section FIRST
3. Read `.ralph/testid-contracts.json` if the story has UI elements
4. Implement the story following acceptance criteria exactly
5. Run quality checks
6. Stage changes (do NOT commit)
7. Update prd.json to set `passes: true`
8. Append progress to `.ralph/progress.txt`

---

## Story Types

### Implementation Stories
Standard development. Include ALL testIDs from contracts.

### Verification Stories (prefix: "VERIFY:")
Run automated tests:
1. Verify all testIDs from phase are in codebase
2. Create/update Maestro test flow
3. Run: `maestro test .ralph/test-flows/[flow].yaml`
4. If tests fail, create FIX stories

### Fix Stories (prefix: "FIX:")
Address specific test failures. Small and focused.

---

## testID Contracts

When implementing UI stories, check `.ralph/testid-contracts.json`:

```json
{
  "storyId": "US-005",
  "screen": "LoginScreen",
  "testIds": [
    { "id": "login-email-input", "element": "TextInput" }
  ]
}
```

**You MUST include every testID:**

```tsx
<TextInput
  testID="login-email-input"
  placeholder="Email"
  ...
/>
```

---

## Quality Checks

Run before staging:

```bash
npx tsc --noEmit
npx expo lint
```

---

## Progress Report

APPEND to `.ralph/progress.txt`:

```
## [Date] - [Story ID] ([storyType])
- What was implemented
- Files changed
- testIDs added (if UI)
- **Learnings:**
  - Patterns discovered
  - Gotchas encountered
---
```

---

## Codebase Patterns

Add reusable patterns to TOP of progress.txt:

```
## Codebase Patterns
- Navigation: expo-router in /app
- Forms: react-hook-form + zod
- State: Zustand in /stores
- API: tanstack-query in /hooks
```

---

## Important Rules

1. **One story per session** - Complete fully before finishing
2. **testIDs are mandatory** - Every UI element needs its contracted testID
3. **Stage only, don't commit** - Use `git add`, not `git commit`
4. **Read progress.txt first** - Learn from previous iterations
5. **Update prd.json** - Mark `passes: true` when done
6. **Append to progress.txt** - Document what you did and learned

---

## Stop Condition

If ALL stories have `passes: true`:
```
<promise>COMPLETE</promise>
```

Otherwise finish normally after updating files.
