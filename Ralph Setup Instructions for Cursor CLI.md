## Ralph Setup Instructions for Cursor CLI

### Prerequisites

```bash
# Required tools
brew install jq

# Convex CLI
npm install -g convex

# Cursor CLI
curl https://cursor.com/install -fsS | bash
```

### Option A: New Project (from scratch)

```bash
# 1. Clone Ralph setup repo
git clone https://github.com/YOUR_USERNAME/ralph-setup.git ~/tools/ralph

# 2. Create new Expo + Convex project
~/tools/ralph/init-project.sh my-app
cd my-app

# 3. Initialize Convex backend
npx convex dev
# Copy the URL it outputs to .env.local:
echo "EXPO_PUBLIC_CONVEX_URL=https://your-deployment.convex.cloud" > .env.local

# 4. Configure Ralph for Cursor
cp .ralph/config.json.template .ralph/config.json
# Edit .ralph/config.json to set: "agent": "cursor"
```

### Option B: Existing Expo Project

```bash
# 1. Clone Ralph setup repo (if not done)
git clone https://github.com/YOUR_USERNAME/ralph-setup.git ~/tools/ralph

# 2. Add Ralph to your project
cd /path/to/your/expo-project
~/tools/ralph/setup.sh .

# 3. Configure for Cursor
sed -i '' 's/"agent": "claude"/"agent": "cursor"/' .ralph/config.json
```

### Convert Your BRS to Stories

```bash
# 1. Add your BRS document
cp /path/to/your-requirements.md docs/

# 2. Start Cursor in the project
cursor .

# 3. In Cursor chat, convert BRS to prd.json:
# > Load the brs-to-ralph skill and convert docs/your-requirements.md
```

### Run Ralph Loop

**Terminal 1 - Start Expo with MCP (for VERIFY stories):**
```bash
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start 2>&1 | tee .ralph/expo.log
```

**Terminal 2 - Run Ralph:**
```bash
./ralph.sh
# Or explicitly:
./ralph.sh --agent cursor
```

### Verify MCP is Working

```bash
# Check MCP servers are configured
agent mcp list

# Should show:
# - expo-mcp
# - Convex
# - greptile

# Test Expo MCP tools
agent mcp list-tools expo-mcp
```

### Project Structure After Setup

```
my-app/
├── .cursor/
│   ├── agents/           # ralph-implementer, ralph-verifier
│   ├── hooks/            # Auto-continue hook
│   ├── cli.json          # CLI permissions
│   └── mcp.json          # MCP server config
├── .ralph/
│   ├── prd.json          # Stories (generated from BRS)
│   ├── progress.txt      # Learnings log
│   ├── testid-contracts.json  # Required testIDs
│   ├── prompt.md         # Agent instructions
│   └── config.json       # Ralph config
├── convex/               # Backend
├── app/                  # Expo screens
└── ralph.sh              # Main loop script
```

### Monitoring Progress

```bash
# Check completed stories
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == true)] | length'

# Check remaining
cat .ralph/prd.json | jq '[.userStories[] | select(.passes == false)] | length'

# Review Expo logs for errors
grep -i "error\|warn" .ralph/expo.log | tail -50
```

### Troubleshooting

| Issue                      | Solution                                            |
| -------------------------- | --------------------------------------------------- |
| `agent: command not found` | Run `curl https://cursor.com/install -fsS \| bash`  |
| MCP tools not working      | Restart Expo with `EXPO_UNSTABLE_MCP_SERVER=1` flag |
| File writes not applying   | Ensure `--force` is in ralph.sh (already done)      |
| Convex errors              | Run `npx convex dev` in background                  |