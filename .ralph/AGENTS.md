# Ralph Agent Patterns

## Overview

Ralph spawns fresh agent instances per story. State persists via files:
- `.ralph/prd.json` - Story status
- `.ralph/progress.txt` - Patterns and learnings
- `.ralph/testid-contracts.json` - Required testIDs
- Git staged files - Actual code

## Key Concepts

### testID Contracts
Every UI element's testID is defined BEFORE development.

### Story Types
1. **implementation** - Build features
2. **verification** - Run tests
3. **fix** - Address failures

### Quality Gates
```bash
npx tsc --noEmit
npx expo lint
```

## Patterns

### testID Naming
```
[screen]-[element]-[purpose]
```

### Story Dependencies
```
Types → Stores → Hooks → Screens → Logic → VERIFY
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Missing testID | Check contract |
| Context exceeded | Split story |
| Repeated errors | Add to Codebase Patterns |
