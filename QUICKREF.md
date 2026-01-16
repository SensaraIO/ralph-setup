# Ralph-CC Quick Reference

## Commands

```bash
# New project
~/tools/ralph-cc/init-new-project.sh my-app

# Existing project
~/tools/ralph-cc/setup.sh .

# Install skill
mkdir -p ~/.claude/skills
cp -r ~/tools/ralph-cc/skills/brs-to-ralph ~/.claude/skills/

# Convert BRS (in Claude Code)
claude
> Load brs-to-ralph skill, convert docs/my-brs.md

# Run
./ralph-cc.sh        # 50 iterations default
./ralph-cc.sh 100    # Custom max

# Check progress
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'
```

## Story Types

| Type | Prefix | Purpose |
|------|--------|---------|
| implementation | - | Build with testIDs |
| verification | VERIFY: | Run Maestro tests |
| fix | FIX: | Fix test failures |

## testID Naming

```
[screen]-[element]-[purpose]
```

Examples:
- `login-email-input`
- `profile-save-btn`
- `home-welcome-text`

## Phase Flow

```
Foundation → Screens → Features → VERIFY → Next Phase
```

## Required Acceptance Criteria

Every story:
```
"TypeScript compiles with no errors",
"Lint passes"
```

UI stories add:
```
"[Element] with testID='screen-element-purpose'"
```

## Files

| File | Purpose |
|------|---------|
| `.ralph/prd.json` | Stories |
| `.ralph/progress.txt` | Learnings |
| `.ralph/testid-contracts.json` | Required testIDs |
| `.ralph/test-flows/*.yaml` | Maestro tests |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Missing testID | Check contract |
| Context exceeded | Split story |
| Same error | Add to Codebase Patterns |
