# Ralph-CC Agent Patterns

## Overview

Ralph-CC spawns fresh Claude Code instances per story. State persists via files:
- `.ralph/prd.json` - Story status
- `.ralph/progress.txt` - Patterns and learnings
- `.ralph/testid-contracts.json` - Required testIDs
- Git staged files - Actual code

## Key Concepts

### testID Contracts
Every UI element's testID is defined BEFORE development. Implementation agents MUST include all contracted testIDs.

### Story Types
1. **implementation** - Build features with testIDs
2. **verification** - Run Maestro tests at phase end
3. **fix** - Address specific test failures

### Quality Gates
Every story must pass:
```bash
npx tsc --noEmit   # TypeScript
npx expo lint      # Linting
```

## Patterns

### testID Naming
```
[screen]-[element]-[purpose]
```
Examples: `login-email-input`, `profile-save-btn`, `home-welcome-text`

### Story Dependencies
```
1. Types → 2. Stores → 3. Hooks → 4. Screens → 5. Logic → 6. VERIFY
```

### Commit Flow
- Agents stage files (`git add`)
- Final commit is manual after review

## Common Issues

| Issue | Solution |
|-------|----------|
| Missing testID | Check contract, add to component |
| Type errors | Check types/index.ts exports |
| Context exceeded | Story too big, split it |
| Repeated errors | Add to Codebase Patterns |

## When to Update This File

Add patterns that:
- Affect all agents
- Prevent recurring issues
- Speed up iterations

Do NOT add:
- Story-specific details
- Temporary workarounds
