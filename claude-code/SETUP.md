# Ralph with Claude Code

## Hook Setup (Optional)

To enable auto-continuation between stories:

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

Tell Claude:
```
Read .ralph/prompt.md and implement all stories in .ralph/prd.json sequentially. 
After each story, update prd.json and continue without stopping.
```

Or use `ralph.sh` which spawns fresh instances.

## For VERIFY Stories

Start the Expo dev server with MCP first:
```bash
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start
```

Then Claude can use Expo MCP tools:
- `automation_take_screenshot`
- `automation_tap_by_testid`
- `automation_find_view_by_testid`

## Convex Development

Keep Convex dev running in a separate terminal:
```bash
npx convex dev
```

This auto-deploys schema changes as Claude makes them.
