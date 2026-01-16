# Ralph-CC

Autonomous AI agent loop for React Native/Expo mobile app development using Claude Code.

Ralph-CC takes a BRS (Business Requirements Specification) document and autonomously implements it story-by-story with integrated testing, fresh context per story, and live output streaming.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         RALPH-CC FLOW                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your BRS Document                                                     │
│        │                                                                │
│        ▼                                                                │
│   ┌─────────────────┐     ┌─────────────────────────────────────────┐  │
│   │ brs-to-ralph    │────▶│ prd.json (stories)                      │  │
│   │ skill           │     │ testid-contracts.json (required IDs)    │  │
│   │                 │     │ test-flows/*.yaml (Maestro tests)       │  │
│   └─────────────────┘     └──────────────────┬──────────────────────┘  │
│                                              │                          │
│                                              ▼                          │
│   ┌──────────────────────────────────────────────────────────────────┐ │
│   │                      ralph-cc.sh                                  │ │
│   │                                                                   │ │
│   │   FOR each story:                                                 │ │
│   │       │                                                           │ │
│   │       ▼                                                           │ │
│   │   ┌─────────────────────────────────────────────────────────┐    │ │
│   │   │ Spawn FRESH Claude Code instance                         │    │ │
│   │   │   • Reads progress.txt for patterns                      │    │ │
│   │   │   • Implements one story                                 │    │ │
│   │   │   • Runs TypeScript + lint checks                        │    │ │
│   │   │   • Updates prd.json (passes: true)                      │    │ │
│   │   │   • Appends learnings to progress.txt                    │    │ │
│   │   │   • Exits (context cleared)                              │    │ │
│   │   └─────────────────────────────────────────────────────────┘    │ │
│   │       │                                                           │ │
│   │       ▼                                                           │ │
│   │   Next story... (fresh context, state preserved in files)         │ │
│   │                                                                   │ │
│   └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│   State preserved between instances:                                    │
│   • .ralph/prd.json ─────────── Which stories are done                 │
│   • .ralph/progress.txt ─────── Patterns & learnings                   │
│   • .ralph/testid-contracts ─── Required testIDs                       │
│   • Git staged files ────────── Actual code written                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

```bash
# Node.js 18+
brew install nvm
nvm install 20

# Expo CLI
npm install -g expo-cli

# Claude Code CLI (requires Anthropic account)
# Follow: https://docs.anthropic.com/claude-code

# Maestro for E2E testing
brew install maestro

# jq for JSON parsing
brew install jq
```

---

## Quick Start (New Project)

### 1. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/ralph-cc.git ~/tools/ralph-cc
```

### 2. Create a new Expo project with Ralph-CC

```bash
~/tools/ralph-cc/init-new-project.sh my-app-name
cd my-app-name
```

This creates an Expo project with:
- All dependencies installed (Zustand, react-hook-form, zod, tanstack-query)
- Ralph-CC configured
- Project structure ready (/types, /stores, /hooks, /schemas)

### 3. Add your BRS document

```bash
cp /path/to/your-client-brs.md docs/
```

If you only have rough client notes, use the template at `docs/BRS-TEMPLATE.md` or ask Claude to create a BRS from your notes.

### 4. Install the skill and convert BRS

```bash
# Install skill
mkdir -p ~/.claude/skills
cp -r ~/tools/ralph-cc/skills/brs-to-ralph ~/.claude/skills/

# Open Claude Code
claude
```

Then tell Claude:
```
Load the brs-to-ralph skill and convert docs/your-brs.md to prd.json
```

### 5. Run Ralph-CC

```bash
./ralph-cc.sh
```

Watch it build your app story-by-story with live output.

---

## Quick Start (Existing Project)

### 1. Run setup in your project

```bash
~/tools/ralph-cc/setup.sh /path/to/your/existing/project
```

### 2. Follow steps 3-5 above

---

## File Structure

```
ralph-cc/
├── README.md                 # This file
├── QUICKREF.md              # Quick reference card
│
├── ralph-cc.sh              # Main execution loop
├── setup.sh                 # Add Ralph-CC to existing project
├── init-new-project.sh      # Create new project with Ralph-CC
│
├── .ralph/                  # Configuration templates
│   ├── prompt.md            # Instructions for implementation agent
│   ├── AGENTS.md            # Patterns for agents
│   └── progress.txt.template
│
├── skills/
│   └── brs-to-ralph/
│       └── SKILL.md         # BRS to prd.json converter
│
├── docs/
│   └── BRS-TEMPLATE.md      # Template for client requirements
│
└── examples/
    ├── prd.json.example
    ├── testid-contracts.json.example
    └── test-flows/
        └── phase-02-onboarding.yaml
```

---

## How Stories Work

### Story Types

| Type | Prefix | Purpose |
|------|--------|---------|
| `implementation` | (none) | Build features with testIDs |
| `verification` | `VERIFY:` | Run Maestro tests at phase end |
| `fix` | `FIX:` | Address test failures |

### Story Sizing

Each story must complete in ONE Claude Code context window.

**Good (one story):**
- Create one screen layout with testIDs
- Add form validation to one screen
- Integrate one API endpoint
- Add one state store

**Too big (split these):**
- "Build authentication" → Login screen, Register screen, Auth store, API hooks
- "Create dashboard" → Layout, Each widget, Data fetching

### Phase Structure

Each phase ends with a VERIFY story:

```
PHASE-01: Foundation
  US-001: Create types
  US-002: Create stores
  US-003: Create API hooks
  US-004: VERIFY: Phase 1

PHASE-02: Auth Screens
  US-005: Welcome screen + testIDs
  US-006: Login screen + testIDs
  US-007: Login validation
  US-008: Login API integration
  US-009: VERIFY: Phase 2 (Maestro tests)
```

---

## testID Contracts

Every UI element gets a testID defined before development:

```json
{
  "storyId": "US-005",
  "screen": "LoginScreen",
  "testIds": [
    { "id": "login-email-input", "element": "TextInput" },
    { "id": "login-submit-btn", "element": "Button" }
  ]
}
```

**Naming convention:** `[screen]-[element]-[purpose]`

Examples:
- `login-email-input`
- `profile-save-btn`
- `home-welcome-text`

---

## Commands Reference

```bash
# Create new project
~/tools/ralph-cc/init-new-project.sh my-app

# Add to existing project
~/tools/ralph-cc/setup.sh .

# Convert BRS (in Claude Code)
claude
> Load brs-to-ralph skill, convert docs/my-brs.md

# Run Ralph-CC
./ralph-cc.sh           # Default 50 iterations
./ralph-cc.sh 100       # Custom max

# Check progress
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'

# See remaining stories
cat .ralph/prd.json | jq '.userStories[] | select(.passes == false) | {id, title}'

# Run Maestro tests manually
maestro test .ralph/test-flows/phase-02.yaml
```

---

## State Files

| File | Purpose | Persists Between |
|------|---------|------------------|
| `.ralph/prd.json` | Story status | ✓ All iterations |
| `.ralph/progress.txt` | Patterns & learnings | ✓ All iterations |
| `.ralph/testid-contracts.json` | Required testIDs | ✓ Read-only |
| `.ralph/test-flows/*.yaml` | Maestro tests | ✓ All iterations |
| Git staged files | Actual code | ✓ All iterations |

---

## Troubleshooting

### "Claude Code command not found"
```bash
which claude
# If not found, install from Anthropic docs
```

### "Story seems stuck"
Check if Claude is still running. The script spawns fresh instances, so each story should complete independently.

### "Context exceeded" during a story
Story is too big. Edit `.ralph/prd.json` and split it:
```json
// Before
{ "id": "US-005", "title": "Build entire profile" }

// After  
{ "id": "US-005", "title": "Create profile layout" }
{ "id": "US-005a", "title": "Add profile validation" }
{ "id": "US-005b", "title": "Integrate profile API" }
```

### "Same error keeps happening"
Add the pattern to `.ralph/progress.txt` under Codebase Patterns:
```markdown
## Codebase Patterns
- This project uses expo-router in /app directory
- Forms must use react-hook-form (not useState)
```

### "Maestro tests failing"
Run manually to debug:
```bash
npx expo start  # Terminal 1
maestro test .ralph/test-flows/phase-02.yaml  # Terminal 2
```

---

## Timeline Expectations

| Phase | Stories | Time |
|-------|---------|------|
| Foundation (types, stores, hooks) | 5-7 | 20-40 min |
| Auth screens | 8-12 | 40-80 min |
| Main features | 15-25 | 90-150 min |
| Polish & settings | 5-10 | 30-60 min |

A typical MVP with onboarding + core features: **3-6 hours autonomous work**

---

## Contributing

1. Fork this repo
2. Make changes
3. Test with a real project
4. Submit PR

---

## License

MIT

---

## Credits

- [Geoffrey Huntley](https://ghuntley.com/ralph/) for the original Ralph pattern
- [Anthropic](https://anthropic.com) for Claude Code
