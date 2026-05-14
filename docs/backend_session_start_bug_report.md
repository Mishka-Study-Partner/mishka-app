# Backend Bug Report: POST /study-with-mishka/sessions/start returns 500

## Summary

All attempts to start a study session via `POST /study-with-mishka/sessions/start` return **500 Internal Server Error** despite valid request bodies that pass schema validation.

---

## Environment

- **API Base URL:** `https://mishka-backend-production.up.railway.app`
- **Authenticated User ID:** `45e6c56e-01b3-4b6a-b58c-35ffd9861eba`
- **Date/Time:** 2026-05-14 ~01:50 UTC+3
- **Client:** Flutter iOS app

---

## Failing Requests

### Request 1 — Call With Mishka mode

```
POST /study-with-mishka/sessions/start
Authorization: Bearer <valid_token>
Content-Type: application/json

{
  "topLevelMode": "call_with_mishka",
  "platform": "ios"
}
```

**Response:**
```json
{
  "success": false,
  "message": "Internal server error",
  "message_en": "Internal server error",
  "message_ar": "حدث خطأ في الخادم",
  "data": null,
  "error": "INTERNAL_ERROR",
  "details": null
}
```
**Status:** 500

---

### Request 2 — Concentration mode (ultradian)

```
POST /study-with-mishka/sessions/start
Authorization: Bearer <valid_token>
Content-Type: application/json

{
  "topLevelMode": "concentration",
  "concentrationPreset": "ultradian",
  "platform": "ios"
}
```

**Response:**
```json
{
  "success": false,
  "message": "Internal server error",
  "message_en": "Internal server error",
  "message_ar": "حدث خطأ في الخادم",
  "data": null,
  "error": "INTERNAL_ERROR",
  "details": null
}
```
**Status:** 500

---

### Request 3 — Concentration mode (classic_pomodoro)

```
POST /study-with-mishka/sessions/start
Authorization: Bearer <valid_token>
Content-Type: application/json

{
  "topLevelMode": "concentration",
  "concentrationPreset": "classic_pomodoro",
  "platform": "ios"
}
```

**Response:** Same 500 as above.

---

## Notes

1. **Validation passes** — previously we received 400 errors for invalid fields (e.g., `modeId`, `focusMinutes` at top level). After fixing the payload to match `StudyWithMishkaStartBody` schema exactly, validation no longer rejects the request — it passes through to the handler which then crashes with 500.

2. **All other Study With Mishka endpoints work correctly:**
   - `GET /study-with-mishka/catalog` → 200 ✓
   - `GET /study-with-mishka/custom-timers` → 200 ✓
   - `POST /study-with-mishka/custom-timers` → 201 ✓
   - `DELETE /study-with-mishka/custom-timers/{id}` → 200 ✓

3. **Possible causes:**
   - Missing database table/column for sessions (migration not run?)
   - Null reference in the session creation handler
   - The swagger spec mentions "Conflict: 400 if another session is already active or paused" — perhaps there's an existing stuck session for this user that causes an unhandled error instead of a proper 400
   - Missing environment variable or service dependency on the production server

4. **Impact:** The mobile app gracefully handles this failure (timer runs locally), but no session data (duration, check-ins, phases) is being recorded on the backend.

---

## Expected Behavior

Per the swagger spec, a successful response should be:

```
Status: 201
{
  "success": true,
  "message": "Created",
  "data": {
    "id": "<session-uuid>",
    ...session fields...
  }
}
```

---

## Suggested Investigation Steps

1. Check server logs for the stack trace associated with this 500 error
2. Verify the `study_sessions` (or equivalent) table exists and has all required columns
3. Check if there are any stuck active/paused sessions for this user that need to be cleaned up
4. Test the endpoint directly via Postman/curl with the same payload to reproduce
5. Verify all required environment variables are set on the production server

---

## Related Endpoints Also Likely Affected

Since they depend on a valid session ID:
- `POST /study-with-mishka/sessions/{id}/pause`
- `POST /study-with-mishka/sessions/{id}/resume`
- `POST /study-with-mishka/sessions/{id}/end`
- `POST /study-with-mishka/sessions/{id}/advance-phase`
- `POST /study-with-mishka/sessions/{id}/check-ins`
- `POST /study-with-mishka/sessions/{id}/call-break/start`
- `POST /study-with-mishka/sessions/{id}/call-break/end`
