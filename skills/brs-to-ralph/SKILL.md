---
name: brs-to-ralph
description: "Convert BRS documents to prd.json for Ralph autonomous development. Generates testID contracts and Maestro test flows."
---

# BRS to Ralph Converter

Converts Business Requirements Specification documents to Ralph format.

## Output Files

1. `.ralph/prd.json` - User stories with testID requirements
2. `.ralph/testid-contracts.json` - Required testIDs per screen
3. `.ralph/test-flows/*.yaml` - Maestro test flows

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
      "title": "Create auth types",
      "testIdContract": "login-screen",
      "acceptanceCriteria": [
        "Email input with testID='login-email-input'",
        "TypeScript compiles",
        "Lint passes"
      ],
      "priority": 1,
      "passes": false
    }
  ]
}
```

---

## Story Sizing

**Each story must complete in ONE context window.**

Right-sized:
- One screen layout
- One form validation
- One API integration

Too big (split):
- "Build authentication" → Store, Login, Register, API
- "Create dashboard" → Layout, Widgets, Data

---

## Phase Structure

```
PHASE-01: Foundation (types, stores, hooks)
  US-001 → US-003
  US-004: VERIFY

PHASE-02: Screens
  US-005 → US-008
  US-009: VERIFY (Maestro)
```

---

## testID Contract Format

```json
{
  "contracts": [
    {
      "storyId": "US-005",
      "screen": "LoginScreen",
      "testIds": [
        { "id": "login-email-input", "element": "TextInput" },
        { "id": "login-submit-btn", "element": "Button" }
      ]
    }
  ]
}
```

Naming: `[screen]-[element]-[purpose]`

---

## Maestro Test Format

```yaml
appId: ${APP_ID}
name: Phase 2 Tests
---
- launchApp:
    clearState: true
- tapOn:
    id: "login-submit-btn"
- assertVisible:
    id: "home-screen"
```

---

## Acceptance Criteria Rules

Always include:
```
"TypeScript compiles with no errors",
"Lint passes"
```

For UI stories:
```
"Email input with testID='login-email-input'"
```

---

## Checklist

- [ ] Stories fit one context window
- [ ] Ordered by dependency
- [ ] UI stories have testIdContract
- [ ] Acceptance criteria include testIDs
- [ ] Each phase ends with VERIFY
- [ ] All stories have `passes: false`
