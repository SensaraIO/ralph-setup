---
name: brs-to-ralph
description: "Convert BRS documents to prd.json format for Ralph-CC. Generates testID contracts and Maestro test flows. Triggers: convert brs to ralph, create prd.json, ralph format"
---

# BRS to Ralph-CC Converter

Converts Business Requirements Specification documents to Ralph-CC format with integrated testing.

## Output Files

1. `.ralph/prd.json` - User stories with testID requirements
2. `.ralph/testid-contracts.json` - Required testIDs per screen
3. `.ralph/test-flows/*.yaml` - Maestro test flows per phase

---

## prd.json Format

```json
{
  "project": "AppName",
  "branchName": "ralph/feature-name",
  "description": "Feature description",
  "phases": [
    { "id": "PHASE-01", "name": "Foundation", "description": "..." }
  ],
  "userStories": [
    {
      "id": "US-001",
      "phaseId": "PHASE-01",
      "storyType": "implementation",
      "title": "Story title",
      "description": "As a [user], I want [feature] so that [benefit]",
      "testIdContract": "screen-name",
      "acceptanceCriteria": [
        "Specific criterion with testID='element-id'",
        "TypeScript compiles with no errors",
        "Lint passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

---

## Story Sizing Rule

**Each story must complete in ONE Claude Code context window.**

### Right-sized:
- Create one screen layout with testIDs
- Add validation to one form
- Integrate one API endpoint
- Create one state store

### Too big (split):
- "Build authentication" → Auth store, Login screen, Register screen, API hooks
- "Create dashboard" → Layout, Each widget, Data fetching

---

## Phase Structure

```
PHASE-01: Foundation
  - Types and interfaces
  - Zustand stores
  - API hooks
  - VERIFY: Phase 1

PHASE-02: Feature Screens
  - Screen layouts with testIDs
  - Form validation
  - API integration
  - VERIFY: Phase 2 (Maestro tests)
```

Every phase ends with a VERIFY story.

---

## testID Contract Format

```json
{
  "contracts": [
    {
      "storyId": "US-005",
      "contractId": "login-screen",
      "screen": "LoginScreen",
      "path": "/app/(auth)/login.tsx",
      "testIds": [
        { "id": "login-email-input", "element": "TextInput", "purpose": "Email entry" },
        { "id": "login-password-input", "element": "TextInput", "purpose": "Password entry" },
        { "id": "login-submit-btn", "element": "Button", "purpose": "Submit form" },
        { "id": "login-error-text", "element": "Text", "purpose": "Error display" }
      ]
    }
  ]
}
```

### Naming Convention
```
[screen]-[element]-[purpose]
```

---

## Maestro Test Flow Format

```yaml
appId: ${APP_ID}
name: Phase 2 Tests
---
# Test: Login Happy Path
- launchApp:
    clearState: true
- tapOn:
    id: "welcome-login-link"
- inputText:
    id: "login-email-input"
    text: "test@example.com"
- inputText:
    id: "login-password-input"
    text: "password123"
- tapOn:
    id: "login-submit-btn"
- assertVisible:
    id: "home-screen"
---
# Test: Login Error
- launchApp:
    clearState: true
- tapOn:
    id: "welcome-login-link"
- inputText:
    id: "login-email-input"
    text: "invalid"
- tapOn:
    id: "login-submit-btn"
- assertVisible:
    id: "login-error-text"
```

---

## Story Types

### implementation (default)
```json
{
  "storyType": "implementation",
  "title": "Create Login screen layout",
  "testIdContract": "login-screen"
}
```

### verification
```json
{
  "storyType": "verification",
  "title": "VERIFY: Run Phase 2 tests"
}
```

### fix (created when tests fail)
```json
{
  "storyType": "fix",
  "title": "FIX: Login error not visible",
  "parentStory": "US-010"
}
```

---

## Acceptance Criteria Rules

**Always include:**
```
"TypeScript compiles with no errors",
"Lint passes"
```

**For UI stories, include testIDs:**
```
"Email input with testID='login-email-input'",
"Submit button with testID='login-submit-btn'"
```

**Never include:**
- Time-based metrics ("loads in 2 seconds")
- Vague criteria ("works correctly")

---

## Conversion Process

1. **Analyze BRS** - Extract user types, features, screens
2. **Map to phases** - Foundation → Core → Features → Polish
3. **Split large stories** - One screen/feature per story
4. **Generate testID contracts** - Define all testIDs per screen
5. **Create acceptance criteria** - Include testIDs explicitly
6. **Add VERIFY stories** - One per phase with Maestro flows
7. **Generate test flows** - Happy path + error cases

---

## Checklist Before Saving

- [ ] Each story completable in one context window
- [ ] Stories ordered by dependency
- [ ] Every UI story has testIdContract reference
- [ ] Acceptance criteria include specific testIDs
- [ ] Each phase ends with VERIFY story
- [ ] testid-contracts.json has all screens
- [ ] test-flows/*.yaml created for each VERIFY
- [ ] All stories have `passes: false`
