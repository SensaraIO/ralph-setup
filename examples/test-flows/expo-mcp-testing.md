# Expo MCP Test Flows

For VERIFY stories, Ralph uses Expo MCP instead of Maestro.

## Setup

Start dev server with MCP (with log capture):
```bash
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start 2>&1 | tee .ralph/expo.log
```

**Important:** Expo must run in a separate terminal - Cursor CLI shell mode has a 30s timeout.

## Cursor CLI MCP Discovery

Before running tests, verify MCP is available:
```bash
agent mcp list              # Should show expo-mcp
agent mcp list-tools expo-mcp  # Show available tools
```

## Example Test: Login Flow

The agent will call these MCP tools via Cursor:

### 1. Verify Login Screen Elements
```
automation_find_view(projectRoot: ".", testID: "login-email-input")
automation_find_view(projectRoot: ".", testID: "login-password-input")
automation_find_view(projectRoot: ".", testID: "login-submit-btn")
```

### 2. Take Initial Screenshot
```
automation_take_screenshot(projectRoot: ".")
```

### 3. Enter Credentials
```
# Tap email field
automation_tap(projectRoot: ".", testID: "login-email-input")
# (Agent types via keyboard simulation)

# Tap password field
automation_tap(projectRoot: ".", testID: "login-password-input")
# (Agent types via keyboard simulation)
```

### 4. Submit Form
```
automation_tap(projectRoot: ".", testID: "login-submit-btn")
```

### 5. Verify Result
```
# Wait for navigation
automation_find_view(projectRoot: ".", testID: "home-screen")
# or
automation_find_view(projectRoot: ".", testID: "login-error-text")
```

### 6. Final Screenshot
```
automation_take_screenshot(projectRoot: ".")
```

### 7. Check Console Logs
```bash
grep -i "error\|warn\|exception" .ralph/expo.log | tail -50
```

## Converting from Maestro

| Maestro | Expo MCP |
|---------|----------|
| `assertVisible: id: "x"` | `automation_find_view(testID: "x")` |
| `tapOn: id: "x"` | `automation_tap(testID: "x")` |
| `takeScreenshot` | `automation_take_screenshot()` |
| `inputText: id: "x"` | Tap + keyboard input |

## Notes

- Expo MCP requires the dev server running with the flag
- Expo runs in separate terminal (Cursor CLI shell mode has 30s timeout)
- Restart your agent after starting/stopping the dev server
- Screenshots are returned as base64 images
- The agent verifies visually what's on screen
- Console logs are captured to `.ralph/expo.log` for error review
