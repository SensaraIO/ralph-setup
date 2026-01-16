# Ralph Quick Reference

## Commands

```bash
# New project
~/tools/ralph/init-project.sh my-app

# Existing project
~/tools/ralph/setup.sh .

# Configure agent
edit .ralph/config.json  # set "agent": "claude" or "cursor"

# Install skill
mkdir -p ~/.claude/skills  # or ~/.cursor/skills
cp -r ~/tools/ralph/skills/brs-to-ralph ~/.claude/skills/

# Convert BRS
claude  # or cursor
> Load brs-to-ralph skill, convert docs/my-brs.md

# Run
./ralph.sh
./ralph.sh --agent cursor
./ralph.sh --max 100

# Progress
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'
```

## Agents

| Agent | Config Value | CLI |
|-------|--------------|-----|
| Claude Code | `claude` | `claude -p` |
| Cursor | `cursor` | `agent -p` |
| Codex | `codex` | `codex --approval-mode full-auto` |
| Aider | `aider` | `aider --yes-always` |

## Story Types

| Type | Prefix | Purpose |
|------|--------|---------|
| implementation | - | Build |
| verification | VERIFY: | Test |
| fix | FIX: | Repair |

## testID Naming

```
[screen]-[element]-[purpose]
```

## Files

| File | Purpose |
|------|---------|
| `.ralph/prd.json` | Stories |
| `.ralph/progress.txt` | Learnings |
| `.ralph/testid-contracts.json` | TestIDs |
| `.ralph/config.json` | Settings |

## Cursor Extras

```bash
# Install subagents
cp -r ~/tools/ralph/cursor/agents ~/.cursor/

# Install hooks
cp ~/tools/ralph/cursor/hooks/* .cursor/hooks/
```

Invoke: `/ralph-implementer US-005` or `/ralph-verifier US-005`
