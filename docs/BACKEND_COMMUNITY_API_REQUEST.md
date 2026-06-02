# Backend request — Our Community API gaps (Flutter integration)

**Date:** June 2, 2026  
**From:** Flutter (`mishka-app`)  
**Re:** Community save/pin, share invites, group chat labels  
**Environment tested:** ngrok dev + production-style JWT user

---

## Re-verification (June 2, 2026 — after backend deploy)

| # | Item | Status | Notes |
|---|------|--------|--------|
| 1 | `isPinned` / `saved` on `GET /user-communities` | **Fixed** | Rows include `isPinned`, `saved`, `pinnedAt`, nested `community` |
| 1b | Pin round-trip | **Fixed** | `POST /pin` → `isPinned: true`; `DELETE /pin` → `false` |
| 2 | `GET /invite` for public community | **Fixed** | `200` with `shareUrl`, `supported`, `joinPayload`, `hint` |
| 2b | `GET /invite` for private | **Fixed** | `200` with `inviteCode`, `inviteToken`, `shareUrl` |
| 3 | `senderDisplay` / `senderRole` on messages | **Fixed** | Present on all sampled messages |
| 4 | `POST /invite` with `{ email }` | **Fixed** | Works; `404` + `INVITE_USER_NOT_FOUND` when email/username is **not registered** in Mishka (expected) |
| 4b | `POST /invite` with `{ username }` | **Fixed** | Same as email; `INVITE_USER_NOT_FOUND` if not registered. Body must be exactly `{ "username": "..." }` (not `userName`). Do not prefix with `@`. |
| 4c | Self-invite | **Fixed** | `400` + `INVITE_SELF_NOT_ALLOWED`; message e.g. *"You cannot invite yourself. You are already in this community."* (`message_ar` included). |

**Note:** `404` on direct invite does **not** mean the route is missing. It usually means **no Mishka user** exists for that email (backend message: *"No Mishka account found for that email or username"*).

**Flutter follow-up:** Uses API pin flags first; always calls `GET /invite`. Shows backend message for `INVITE_USER_NOT_FOUND` and `INVITE_SELF_NOT_ALLOWED`. Dialog copy explains invitee must already have an account; client still blocks self-invite before POST when possible.

Run: `TEST_EMAIL=... TEST_PASSWORD=yourpassword ./tool/verify_community_backend_fixes.sh`  
(Do not use `dart run tool/...` from the Flutter root — it hits a native_assets error. Use the shell script or `cd tool/api_verify && dart run verify_community_backend_fixes`.)

---

## Summary

Flutter has shipped Our Community (hub, discover, chat, save/unsave, share dialogs). Three areas still depend on backend fields or endpoints that are **missing or inconsistent** in live responses. We added a **client-side pinned-id cache** as a temporary workaround for (1); we need backend fixes for correct multi-device sync and to remove workarounds.

---

## 1. Saved communities — `isPinned` not returned on memberships (P0)

### Expected
After `POST /communities/{communityId}/pin`, the community should appear in the app’s **Saved Communities** section when we reload hub data.

### Actual
- `POST /communities/{id}/pin` appears to succeed (Flutter shows success).
- `GET /user-communities` returns membership rows **without** a pinned/saved flag, e.g.:

```json
{
  "id": "0f782082-5f09-410c-9fab-cb2095b2d974",
  "userId": "022d11a7-f176-4b05-96e7-5ca884e9b54a",
  "communityId": "ea4f8958-b9cf-463f-8e30-6aec43037d4c",
  "role": "owner"
}
```

- `GET /communities` list items also omit `isPinned` / `saved` for the current user.

### Request
Please include on **each** `user-communities` row (and optionally on community detail when the caller is a member):

| Field | Type | Notes |
|-------|------|--------|
| `isPinned` | `boolean` | `true` after pin |
| *(or)* `saved` | `boolean` | alias acceptable |
| *(optional)* `pinnedAt` | ISO datetime | for ordering saved list |

`DELETE /communities/{id}/pin` should clear the flag on subsequent `GET /user-communities`.

### Flutter workaround (until fixed)
We persist pinned community IDs locally after pin/unpin. This does **not** sync across devices or reinstalls.

---

## 2. Share invite — `GET /communities/{id}/invite` fails for public communities (P1)

### Expected
Owners/admins can open **Send link** / **Create code** for any community they manage (public or private).

### Actual
For a **public** community (`visibility: public`, `inviteCode: null`, `inviteToken: null`):

```http
GET /communities/ea4f8958-b9cf-463f-8e30-6aec43037d4c/invite
```

```json
{
  "success": false,
  "error": "VALIDATION_ERROR",
  "message": "Validation failed"
}
```

This caused an unhandled error in Flutter before we skipped the call for public communities and built a fallback share URL.

### Request
Pick one approach and document in Swagger:

**Option A — Support public invites**  
Return `200` with e.g. `{ "shareUrl": "...", "inviteCode": null }` or a community-id-based join link.

**Option B — Private only**  
Return `200` with `{ "supported": false, "reason": "public_community" }` (not 400) so clients can show copy without treating it as an error.

**Option C — Document**  
State in API docs that `/invite` is private-only; Flutter will keep public fallbacks.

---

## 3. Group chat — `senderDisplay` / `senderRole` on messages (P1)

### Expected
Message list includes display name and role for each sender (Owner / Admin / Member), per discover/chat handoff.

### Actual
`GET /communities/{id}/channels/{channelId}/messages` often returns messages **without** `senderDisplay` or `senderRole`. Flutter enriches from `GET /members` + `ownerUserId`, but that is extra round-trips and can be wrong if membership role is stale.

### Request
On each message object, include when possible:

| Field | Example |
|-------|---------|
| `senderDisplay` | `"norhan mohamed"` |
| `senderRole` | `"owner"` \| `"admin"` \| `"member"` |
| `senderUserId` | UUID (if not already present) |

Same shape already used on channel list (`createdByDisplay`) is ideal.

---

## 4. Direct invite by email / username (P2 — UI ready, API unclear)

Flutter has **Insert Email** and **Insert Username** in the share menu. We plan to call:

```http
POST /communities/{communityId}/invite
Content-Type: application/json

{ "email": "friend@example.com" }
```

or

```json
{ "username": "norhan_mohamed_6193f4" }
```

Please confirm the canonical path and body (or add `POST /communities/{id}/invites` / `POST /communities/{id}/members/invite`) and document success response (e.g. invitation sent vs immediate join).

---

## Verification curls (replace `$TOKEN` and ids)

```bash
# 1) Pin then list memberships
curl -s -H "Authorization: Bearer $TOKEN" -X POST \
  "$BASE/communities/$COMMUNITY_ID/pin"
curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE/user-communities" | jq '.data[] | {communityId, isPinned, saved, role}'

# 2) Public community invite
curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE/communities/$PUBLIC_COMMUNITY_ID/invite"

# 3) Messages
curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE/communities/$COMMUNITY_ID/channels/$CHANNEL_ID/messages" \
  | jq '.data[0] | {senderUserId, senderDisplay, senderRole, content}'
```

---

## Priority

| Priority | Item | Blocks |
|----------|------|--------|
| **P0** | `isPinned` / `saved` on `GET /user-communities` | Saved Communities hub, cross-device save |
| **P1** | Public community invite behavior (200 + contract, not 400) | Share link/code without fallbacks |
| **P1** | `senderDisplay` / `senderRole` on messages | Correct chat labels without client guessing |
| **P2** | Email/username invite POST contract | Share menu “Insert Email/Username” |

Please reply with which option you choose for (2) and the field names you standardize for (1). Flutter can adjust parsers in the same release.

---

**Contact:** Flutter team — `mishka-app` / Our Community feature branch
