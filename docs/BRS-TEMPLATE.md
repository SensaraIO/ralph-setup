# BRS Template

Use this template to structure client requirements before converting to Ralph-CC format.

---

## 1. App Overview

**App Name:** [Name]

**Description:** 
[What the app does and who it's for]

**Platform:** iOS, Android (React Native/Expo)

---

## 2. User Types

| User Type | Description |
|-----------|-------------|
| Guest | Unauthenticated user |
| User | Standard authenticated user |
| Admin | Backend management |

---

## 3. Features

### 3.1 [Feature Category]

#### User Story: [Feature Name]

As a [user type], I want to [action] so that [benefit].

**Screen Elements:**
- [Element 1]
- [Element 2]
- [Element 3]

**Flow:**
1. User navigates to **[Screen]**
2. User [action]
3. System [response]
4. Success → **[Next Screen]**

---

## 4. Screen List

| Screen | Purpose |
|--------|---------|
| Welcome | Entry point |
| Login | Authentication |
| Home | Main dashboard |

---

## 5. Quick Conversion

If you only have rough notes:

```
I have these client requirements. Create a BRS:

[paste notes here]
```

Then convert:

```
Load brs-to-ralph skill, convert docs/my-brs.md
```
