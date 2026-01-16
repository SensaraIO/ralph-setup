# Ralph

Autonomous AI agent loop for mobile app development. Works with any CLI-based AI coding agent.

Ralph takes a BRS (Business Requirements Specification) document and autonomously implements it story-by-story with integrated testing, fresh context per story, and live output.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

---

## Supported Agents

| Agent | Command | Status |
|-------|---------|--------|
| Claude Code | `claude` | ✅ Tested |
| Cursor CLI | `cursor` or `agent` | ✅ Supported |
| Codex CLI | `codex` | ✅ Supported |
| Aider | `aider` | ✅ Supported |
| Amp | `amp` | ✅ Supported |

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           RALPH FLOW                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   Your BRS Document                                                     │
│        │                                                                │
│        ▼                                                                │
│   ┌─────────────────┐     ┌─────────────────────────────────────────┐  │
│   │ brs-to-ralph    │────▶│ prd.json + testid-contracts.json        │  │
│   │ skill           │     │ + test-flows/*.yaml                     │  │
│   └─────────────────┘     └──────────────────┬──────────────────────┘  │
│                                              │                          │
│                                              ▼                          │
│   ┌──────────────────────────────────────────────────────────────────┐ │
│   │                        ralph.sh                                   │ │
│   │                                                                   │ │
│   │   FOR each story:                                                 │ │
│   │       │                                                           │ │
│   │       ▼                                                           │ │
│   │   ┌─────────────────────────────────────────────────────────┐    │ │
│   │   │ Spawn FRESH agent instance (claude/cursor/codex/aider)   │    │ │
│   │   │   • Reads progress.txt for patterns                      │    │ │
│   │   │   • Implements one story                                 │    │ │
│   │   │   • Runs quality checks                                  │    │ │
│   │   │   • Updates prd.json (passes: true)                      │    │ │
│   │   │   • Exits (context cleared)                              │    │ │
│   │   └─────────────────────────────────────────────────────────┘    │ │
│   │       │                                                           │ │
│   │       ▼                                                           │ │
│   │   Next story... (fresh context, state in files)                   │ │
│   └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│   State preserved between instances:                                    │
│   • .ralph/prd.json ─────────── Story completion status                │
│   • .ralph/progress.txt ─────── Patterns & learnings                   │
│   • .ralph/testid-contracts ─── Required testIDs                       │
│   • Git staged files ────────── Actual code                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

```bash
# Required
brew install jq

# For testing
brew install maestro

# Install your preferred agent CLI:

# Claude Code
# https://docs.anthropic.com/claude-code

# Cursor CLI
# https://cursor.com/install
curl https://cursor.com/install -fsS | bash

# Codex CLI
npm install -g @openai/codex

# Aider
pip install aider-chat

# Amp
# https://ampcode.com
```

---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/ralph.git ~/tools/ralph
```

### 2. Create a new project

```bash
~/tools/ralph/init-project.sh my-app
cd my-app
```

### 3. Configure your agent

Edit `.ralph/config.json`:
```json
{
  "agent": "claude"
}
```

Options: `claude`, `cursor`, `codex`, `aider`, `amp`

### 4. Add your BRS and convert

```bash
cp /path/to/your-brs.md docs/

# Using Claude Code:
claude
> Load the brs-to-ralph skill, convert docs/your-brs.md

# Using Cursor:
cursor
> Load the brs-to-ralph skill, convert docs/your-brs.md
```

### 5. Run Ralph

```bash
./ralph.sh
```

---

## Agent-Specific Setup

### Claude Code

```bash
# Install skill
mkdir -p ~/.claude/skills
cp -r ~/tools/ralph/skills/brs-to-ralph ~/.claude/skills/
```

### Cursor

```bash
# Install skill (Cursor supports .claude/skills)
mkdir -p ~/.cursor/skills
cp -r ~/tools/ralph/skills/brs-to-ralph ~/.cursor/skills/

# Optional: Install subagents for parallel execution
cp -r ~/tools/ralph/cursor/agents ~/.cursor/

# Optional: Install hooks for automation
cp -r ~/tools/ralph/cursor/hooks ~/.cursor/
```

### Codex

```bash
# Codex uses the prompt directly, no skill installation needed
# Just run ralph.sh with agent set to "codex"
```

### Aider

```bash
# Aider uses the prompt directly
# Just run ralph.sh with agent set to "aider"
```

---

## Configuration

### `.ralph/config.json`

```json
{
  "agent": "claude",
  "model": null,
  "maxIterations": 50,
  "autoCommit": false,
  "qualityChecks": {
    "typescript": "npx tsc --noEmit",
    "lint": "npx expo lint"
  }
}
```

| Field | Description | Default |
|-------|-------------|---------|
| `agent` | Which CLI agent to use | `claude` |
| `model` | Model override (agent-specific) | `null` (agent default) |
| `maxIterations` | Max stories before stopping | `50` |
| `autoCommit` | Commit after each story | `false` |
| `qualityChecks` | Commands to run for verification | See above |

---

## File Structure

```
ralph/
├── README.md
├── QUICKREF.md
│
├── ralph.sh                    # Main loop (agent-agnostic)
├── setup.sh                    # Add to existing project
├── init-project.sh             # Create new project
│
├── .ralph/
│   ├── prompt.md               # Agent instructions
│   ├── AGENTS.md               # Patterns documentation
│   └── config.json.template    # Config template
│
├── skills/
│   └── brs-to-ralph/
│       └── SKILL.md            # Works with Claude & Cursor
│
├── cursor/                     # Cursor-specific extras
│   ├── agents/
│   │   ├── ralph-implementer.md
│   │   └── ralph-verifier.md
│   └── hooks/
│       └── hooks.json
│
├── docs/
│   └── BRS-TEMPLATE.md
│
└── examples/
    ├── prd.json.example
    ├── testid-contracts.json.example
    └── test-flows/
```

---

## Using with Cursor Subagents

Cursor supports subagents for parallel execution. Ralph includes two subagents:

### ralph-implementer
Implements one story at a time following the prompt.md instructions.

### ralph-verifier  
Validates completed work, checks testIDs, runs quality checks.

To use:
```bash
# In Cursor
> /ralph-implementer implement US-005 from .ralph/prd.json
> /ralph-verifier verify US-005 was completed correctly
```

Or let Cursor's agent delegate automatically based on the task.

---

## Using with Cursor Hooks

Cursor hooks can automate the Ralph loop:

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": ".cursor/hooks/ralph-continue.sh"
      }
    ]
  }
}
```

The hook checks for remaining stories and triggers continuation.

---

## Commands Reference

```bash
# Create new project
~/tools/ralph/init-project.sh my-app

# Add to existing project  
~/tools/ralph/setup.sh .

# Run Ralph loop
./ralph.sh              # Uses config.json settings
./ralph.sh --agent cursor    # Override agent
./ralph.sh --max 100         # Override max iterations

# Check progress
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'

# See remaining
cat .ralph/prd.json | jq '.userStories[] | select(.passes == false) | {id, title}'
```

---

## Troubleshooting

### "Agent command not found"
Ensure the CLI is installed and in your PATH:
```bash
which claude    # or cursor, codex, aider
```

### "Context exceeded"
Story is too big. Split it in `.ralph/prd.json`.

### "Same error repeating"
Add pattern to `.ralph/progress.txt` under Codebase Patterns.

### "Cursor hooks not working"
Ensure hooks.json is at `.cursor/hooks.json` and Cursor is restarted.

---

## Contributing

1. Fork this repo
2. Make changes
3. Test with multiple agents
4. Submit PR

---

## License

MIT
