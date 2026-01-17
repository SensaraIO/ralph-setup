# BRS Template

Structure client requirements before converting to Ralph format.

---

## 1. App Overview

**App Name:** [Name]

**Description:** [What it does]

**Platform:** iOS, Android (Expo)

**Backend:** Convex

---

## 2. User Types

| Type | Description |
|------|-------------|
| Guest | Unauthenticated |
| User | Standard user |
| Admin | Management |

---

## 3. Data Entities

List all data that needs to be stored:

| Entity | Fields | Notes |
|--------|--------|-------|
| User | email, name, passwordHash, profileComplete | Index by email |
| Post | title, content, authorId, createdAt | Reference users |

---

## 4. Features

### 4.1 [Feature Category]

#### User Story: [Name]

As a [user], I want [action] so that [benefit].

**Screen Elements:**
- [Element 1]
- [Element 2]

**Data Operations:**
- Create [entity]
- Read [entity]
- Update [entity]

**Flow:**
1. User → **[Screen]**
2. Action → Result

---

## 5. Screen List

| Screen | Purpose | Data Needed |
|--------|---------|-------------|
| Welcome | Entry | None |
| Login | Auth | User lookup |
| Home | Dashboard | User data |

---

## Quick Conversion

```
Load brs-to-ralph skill, convert docs/my-brs.md
```

This generates:
- Backend stories (Convex schema + functions)
- Frontend stories (Expo screens)
- testID contracts
