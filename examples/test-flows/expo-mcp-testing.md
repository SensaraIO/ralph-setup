# Expo MCP Test Flows

For VERIFY stories, Ralph uses Expo MCP instead of Maestro.

## Setup

Start dev server with MCP:
```bash
EXPO_UNSTABLE_MCP_SERVER=1 npx expo start
```

## Example Test: Login Flow

The agent will execute these MCP commands:

### 1. Verify Login Screen Elements
```
automation_find_view_by_testid('login-email-input')
automation_find_view_by_testid('login-password-input')
automation_find_view_by_testid('login-submit-btn')
```

### 2. Take Initial Screenshot
```
automation_take_screenshot()
```

### 3. Enter Credentials
```
# Type in email field
automation_tap_by_testid('login-email-input')
# (Agent types via keyboard simulation)

# Type in password field
automation_tap_by_testid('login-password-input')
# (Agent types via keyboard simulation)
```

### 4. Submit Form
```
automation_tap_by_testid('login-submit-btn')
```

### 5. Verify Result
```
# Wait for navigation
automation_find_view_by_testid('home-screen')
# or
automation_find_view_by_testid('login-error-text')
```

### 6. Final Screenshot
```
automation_take_screenshot()
```

## Converting from Maestro

| Maestro | Expo MCP |
|---------|----------|
| `assertVisible: id: "x"` | `automation_find_view_by_testid('x')` |
| `tapOn: id: "x"` | `automation_tap_by_testid('x')` |
| `takeScreenshot` | `automation_take_screenshot()` |
| `inputText: id: "x"` | Tap + keyboard input |

## Notes

- Expo MCP requires the dev server running with the flag
- Restart your agent after starting/stopping the dev server
- Screenshots are returned as base64 images
- The agent verifies visually what's on screen
