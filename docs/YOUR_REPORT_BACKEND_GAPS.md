# Backend Gap Report: Your Report Screen

**Date:** May 24, 2026 (gaps) · **Backend shipped:** May 30, 2026  
**From:** Flutter team (`mishka-app`)  
**Audience:** Backend team  

> **Status:** All P0/P1/P2 items below are **implemented on the backend**.  
> **Flutter integration:** follow [`FLUTTER_YOUR_REPORT_HANDOFF.md`](./FLUTTER_YOUR_REPORT_HANDOFF.md) — the app still uses the **old multi-call client logic** until migrated.  
> **Our Community** is tracked separately: see [`COMMUNITY_FLUTTER_STATUS.md`](./COMMUNITY_FLUTTER_STATUS.md) and [`COMMUNITY_E2E_TEST.md`](./COMMUNITY_E2E_TEST.md).

**Related docs:**
- [`FLUTTER_YOUR_REPORT_HANDOFF.md`](./FLUTTER_YOUR_REPORT_HANDOFF.md) — **start here** (bundle API, PDF export, auto-email)
- [`FLUTTER_BACKEND_CHANGELOG.md`](./FLUTTER_BACKEND_CHANGELOG.md) — full backend changelog (May 13–30)
- [`YOUR_REPORT_PDF_SERVER_SPEC.md`](./YOUR_REPORT_PDF_SERVER_SPEC.md) — visual PDF spec (backend implements this)

---

## Summary

The Flutter **Your Report** screen is live and reads **real backend data** for study time, daily streak, tasks, and (partially) AI tool usage. The gap items in this document were **requested May 24** and **delivered by backend May 30**. Remaining work is **Flutter migration** to the new unified APIs (see handoff doc checklist).

---

## What the app uses today (working integration)

| Report section | Backend endpoints | Client-side work |
|----------------|-------------------|------------------|
| **Study with Mishka** (daily / weekly / monthly / yearly charts) | `GET /study-with-mishka/reports/day` | Two calls per period: `topLevelMode=concentration` + `topLevelMode=call_with_mishka`, merged in app |
| | `GET /study-with-mishka/reports/week` | Same dual-mode merge |
| | `GET /study-with-mishka/reports/month` | Same dual-mode merge; **yearly view = 12 × 2 = 24 requests** |
| **Daily Streak** (top of screen) | `GET /daily-streaks` | Week row (Mon–Sun) on **weekly** tab only; all periods show current / longest / freezes summary |
| **Tasks completed** (bottom bar chart) | `GET /tasks` | Counts completed tasks per day; buckets by completion date in app (see fallbacks below) |
| **AI tools usage** | `GET /chat-sessions` (embedded `messages`) | Counts `tool_preview` messages in date range; parses JSON `messageContent` |

**Auth:** All routes require JWT (`Authorization: Bearer <token>`).

**Base URL (production):** `https://mishka-backend-production-3f6f.up.railway.app`

---

## Gaps — backend work needed

### 1. Combined study report (both modes in one response) — **High priority**

**Problem:** Product requires total study time across **Concentration mode** and **Camera mode** (`call_with_mishka`). The report APIs require `topLevelMode` per request, so the app makes **2× requests** for every day/week/month query.

**Impact:**
- Weekly report: 2 requests  
- Monthly report: 2 requests  
- Yearly report: **24 requests** (12 months × 2 modes)  
- Slower load, more failure points, harder to cache

**Recommendation (pick one):**

**Option A — Omit or wildcard `topLevelMode`**
```
GET /study-with-mishka/reports/week?date=2026-05-19
→ totals + sessionSummaries for ALL modes combined
```

**Option B — Explicit combined mode**
```
GET /study-with-mishka/reports/week?date=2026-05-19&topLevelMode=all
```

**Option C — Dedicated aggregate endpoint**
```
GET /study-with-mishka/reports/summary?period=year&year=2026
→ { studyMinutesByBucket[], totals, modesBreakdown? }
```

**Expected response shape (unchanged fields, merged data):**
```json
{
  "success": true,
  "data": {
    "totals": {
      "sumApproximateMainStudySeconds": 5400
    },
    "sessionSummaries": [
      {
        "startedAt": "2026-05-20T10:00:00.000Z",
        "approximateMainStudySeconds": 1800,
        "topLevelMode": "concentration"
      },
      {
        "startedAt": "2026-05-20T15:00:00.000Z",
        "approximateMainStudySeconds": 900,
        "topLevelMode": "call_with_mishka"
      }
    ]
  }
}
```

---

### 2. Yearly study report endpoint — **High priority**

**Problem:** No `GET /study-with-mishka/reports/year`. The app aggregates 12 monthly calls (×2 modes = 24 requests).

**Recommendation:**
```
GET /study-with-mishka/reports/year?year=2026&topLevelMode=all
```

Return 12 buckets (Jan–Dec) with `sumApproximateMainStudySeconds` per month and optional `sessionSummaries` or pre-aggregated monthly totals only.

---

### 3. PDF export / email delivery — **Medium priority**

**Full visual + API spec:** [`YOUR_REPORT_PDF_SERVER_SPEC.md`](./YOUR_REPORT_PDF_SERVER_SPEC.md)

**Problem:** UI previously said “send link to email”. There is **no backend PDF or email API**. The app now generates PDF **locally** and opens the **system share sheet**. The local PDF is **plain text only** and does **not** match the on-screen chart design.

**If product still wants email delivery, backend should provide:**

```
POST /study-with-mishka/reports/export
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "period": "weekly",
  "date": "2026-05-19",
  "delivery": "email"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "pdfUrl": "https://.../signed-url.pdf",
    "expiresAt": "2026-05-25T00:00:00.000Z",
    "emailedTo": "user@example.com"
  }
}
```

Alternatively, a generic `POST /reports/email` that accepts a pre-built PDF upload (multipart) or server-side generation from the same report aggregation logic.

---

### 4. AI tool usage report API — **High priority**

**Problem:** The app counts AI usage by scanning **all** `GET /chat-sessions` and embedded messages for `inputType: "tool_preview"`. This is:
- Expensive (full session list + message payload)
- Fragile (depends on message JSON shape)
- Incomplete (`/user-ai-activity` exists in routes but is **unused** — unclear if it supports date-range aggregates)

**Endpoints defined in app but not used for reports:**
- `GET /user-ai-activity`
- `GET /study-with-mishka/stats/summary` (purpose unclear for Your Report)

**Recommendation — dedicated report endpoint:**
```
GET /user-ai-activity/report?from=2026-05-01&to=2026-05-31
```

**Response:**
```json
{
  "success": true,
  "data": {
    "quizzes": 12,
    "flashcards": 8,
    "summaries": 5,
    "mindMaps": 3,
    "periodStart": "2026-05-01T00:00:00.000Z",
    "periodEnd": "2026-06-01T00:00:00.000Z"
  }
}
```

Flutter will switch to this endpoint once available. Until then, mind maps are counted in code but **not shown** in the UI (only 3 rings).

---

### 5. Historical daily streak (beyond current ISO week) — **Medium priority**

**Problem:** `GET /daily-streaks` returns the **current week only** (`week[]` with 7 days). Your Report **weekly** tab shows the home-style week row. **Monthly** and **yearly** tabs can only show `currentStreak`, `longestStreak`, `freezesRemaining` — no per-day or per-week streak history chart.

**Recommendation:**
```
GET /daily-streaks/history?from=2026-05-01&to=2026-05-31
```

**Response:**
```json
{
  "success": true,
  "data": {
    "currentStreak": 5,
    "longestStreak": 14,
    "freezesRemaining": 2,
    "days": [
      { "date": "2026-05-01", "state": "past_done" },
      { "date": "2026-05-02", "state": "past_missed" }
    ]
  }
}
```

Or include streak buckets inside a unified `GET /reports/dashboard` payload.

---

### 6. Task completion date + tasks report API — **High priority**

**Problem:** The bottom **Tasks completed** chart shows how many to-do items the user marked done **each day** (Mon–Sun on weekly, day-of-month on monthly, etc.). The app fetches **all** tasks via `GET /tasks` and buckets them client-side.

**Current Flutter fallbacks for “when was this task completed?” (in order):**
1. `completedAt` / `completed_at` / `finishedAt`
2. `updatedAt` / `updated_at` (set on any task edit, not just completion)
3. `deadline` / `dueDate` (last resort — **wrong** for reporting)

**Impact:**
- Chart may show **zero or wrong data** if the API does not return a reliable completion timestamp
- `updatedAt` attributes completions to the wrong day if the user edited the task later
- `deadline` misattributes tasks completed early/late relative to due date
- Loading every task for every report period does not scale

**Recommendation — add canonical field on task responses:**
```json
{
  "id": "uuid",
  "title": "Finish chapter 3",
  "status": "completed",
  "completedAt": "2026-05-20T14:30:00.000Z",
  "dueDate": "2026-05-21T00:00:00.000Z"
}
```

**Set `completedAt` when:** `PATCH /tasks/{id}` sets `status: "completed"` (and clear it when reopened).

**Recommendation — dedicated report endpoint (preferred):**
```
GET /tasks/report/completions?from=2026-05-19&to=2026-05-26&granularity=day
```

**Response:**
```json
{
  "success": true,
  "data": {
    "buckets": [
      { "label": "2026-05-19", "completedCount": 2 },
      { "label": "2026-05-20", "completedCount": 0 }
    ],
    "totalCompleted": 2
  }
}
```

Flutter will switch to this endpoint once available and stop scanning the full task list.

---

### 7. Community activity section — **Low priority (feature not shipped)**

**Problem:** Design originally included “Activity in Community”. No backend endpoint provides per-period community engagement (posts, shares, group activity). Section was **removed** from the app until an API exists.

**Recommendation:** Define metrics and expose e.g.:
```
GET /communities/activity/report?period=weekly&date=2026-05-19
```

---

### 8. Unified “Your Report” bundle endpoint — **Nice to have**

**Problem:** Loading one report period triggers **parallel** calls to study reports (×2 modes), chat sessions, daily streaks, and tasks. A single bundle would reduce latency and simplify caching.

**Recommendation:**
```
GET /reports/your-report?period=weekly&date=2026-05-19
```

**Response sections:**
```json
{
  "success": true,
  "data": {
    "periodLabel": "May 19 – May 25, 2026",
    "study": { "buckets": [], "totals": {} },
    "aiTools": { "quizzes": 0, "flashcards": 0, "summaries": 0, "mindMaps": 0 },
    "streak": { "currentStreak": 0, "longestStreak": 0, "freezesRemaining": 0, "week": [] },
    "tasksCompleted": { "buckets": [{ "label": "Mon", "completedCount": 1 }] }
  }
}
```

---

## Session data dependency (operational note)

Study charts only include sessions **persisted on the backend** via `POST /study-with-mishka/sessions/start` → … → `POST …/end`. If session start fails (historically 500 — see [`STUDY_WITH_MISHKA_FIX_REPORT.md`](./STUDY_WITH_MISHKA_FIX_REPORT.md)), the app may run the timer locally; those minutes **will not appear** in reports until start/end succeeds.

**Backend should ensure:**
- Session start/end stable for both `concentration` and `call_with_mishka`
- Report aggregation includes completed **and** abandoned sessions per product rules
- Consistent field names in `sessionSummaries`: `approximateMainStudySeconds` (or document aliases)

---

## Field name consistency (study session summaries)

Flutter currently accepts these keys when parsing sessions:

| Purpose | Keys tried (in order) |
|---------|------------------------|
| Study seconds | `approximateMainStudySeconds`, `studySeconds`, `mainStudySeconds` |
| Start time | `startedAt`, `startUtc`, `createdAt` |
| Report totals | `totals.sumApproximateMainStudySeconds`, `sumStudySeconds`, `sumMainStudySeconds` |

Please **document the canonical names** in OpenAPI/README so both modes return the same shape.

---

## Field name consistency (task completion)

Flutter currently accepts these keys when determining completion date:

| Purpose | Keys tried (in order) |
|---------|------------------------|
| Completion time | `completedAt`, `completed_at`, `finishedAt`, `finished_at` |
| Fallback | `updatedAt`, `updated_at` |
| Last resort | `deadline`, `dueDate`, `dueAt`, `date` |

**Backend should add and populate `completedAt`** — do not rely on fallbacks for accurate reporting.

---

## Priority checklist for backend

| Priority | Item | Unblocks |
|----------|------|----------|
| P0 | Combined study report (`topLevelMode=all` or omit filter) | Correct totals without double fetch |
| P0 | `GET /study-with-mishka/reports/year` | Fast yearly tab |
| P0 | AI usage report with date range + mind maps | Replace chat-session scraping |
| P0 | `completedAt` on tasks + `GET /tasks/report/completions` | Accurate tasks-completed chart |
| P1 | PDF generate + email (or signed URL) | Optional email delivery |
| P1 | Daily streak history for month/year | Streak charts on non-weekly tabs |
| P2 | Community activity report | Community section in Your Report |
| P2 | Unified `GET /reports/your-report` | Performance + simpler client |

---

## Flutter changes made (May 24, 2026)

- Study subtitle: **“Total study time (Concentration + Camera modes)”**
- PDF button: **“Create PDF and share”** (local generation + system share sheet)
- Study reports fetch and merge both `concentration` and `call_with_mishka`
- **Daily Streak** section moved to **top** of report (home-style week row on weekly tab)
- **Tasks completed** bar chart at **bottom** — one bar per day, count of tasks marked done (separate from streak)
- Removed explanatory hint line under tasks section

---

## Contact / verification

To verify study report APIs manually (replace token and date):

```bash
# Concentration
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://mishka-backend-production-3f6f.up.railway.app/study-with-mishka/reports/week?date=2026-05-19&topLevelMode=concentration"

# Camera mode
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://mishka-backend-production-3f6f.up.railway.app/study-with-mishka/reports/week?date=2026-05-19&topLevelMode=call_with_mishka"
```

Compare `totals.sumApproximateMainStudySeconds` and `sessionSummaries` length — app sums both for the Study with Mishka chart.

---

**Next step for backend:** Confirm which of the P0 items can ship first; Flutter can integrate incrementally without UI redesign.

---

## Backend delivery status (May 30, 2026)

| Gap # | Item | Backend status |
|-------|------|----------------|
| 1 | Combined study report (`topLevelMode=all`) | **Shipped** |
| 2 | Yearly study report endpoint | **Shipped** — `GET /study-with-mishka/reports/year` |
| 3 | PDF export / email | **Shipped** — `POST /reports/your-report/export` |
| 4 | AI usage report API | **Shipped** — `GET /user-ai-activity/report` |
| 5 | Daily streak history | **Shipped** — `GET /daily-streaks/history` |
| 6 | Task `completedAt` + completions report | **Shipped** — migration + `GET /tasks/report/completions` |
| 7 | Community activity report | **Shipped** — in bundle + dedicated endpoint |
| 8 | Unified bundle endpoint | **Shipped** — `GET /reports/your-report?format=bundle` |
| — | Auto report email opt-in | **Shipped** — `GET/PATCH /user-preferences/me` |

**Flutter still TODO:** See migration checklist in [`FLUTTER_YOUR_REPORT_HANDOFF.md`](./FLUTTER_YOUR_REPORT_HANDOFF.md).
