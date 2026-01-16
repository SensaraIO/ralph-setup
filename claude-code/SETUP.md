# Ralph with Claude Code

## Hook Setup (Optional)

Claude Code uses a different hooks system. To enable auto-continuation:

1. Open Claude Code in your project
2. Run `/hooks`
3. Select "Stop - Right before Claude concludes"
4. Paste this command:

```bash
remaining=$(jq '[.userStories[] | select(.passes == false)] | length' .ralph/prd.json 2>/dev/null); if [ "$remaining" -gt 0 ]; then echo "Continue: $remaining stories remaining. Implement the next story with passes: false in .ralph/prd.json" >&2; exit 2; fi; exit 0
```

5. Press Enter to confirm

## Exit Codes

- `exit 0` = Stop normally
- `exit 2` = Show message to Claude and continue

## Without Hooks

Just tell Claude:
```
Read .ralph/prompt.md and implement all stories in .ralph/prd.json sequentially. After each story, update prd.json and continue without stopping.
```

Or use the `ralph.sh` script which spawns fresh instances automatically.
