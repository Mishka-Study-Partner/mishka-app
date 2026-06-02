# Our Community — Flutter integration status

**Updated:** June 2026

## Implemented

| Area | Status |
|------|--------|
| Hub (saved / my private / my public / recommended) | Done |
| Discover + recommended APIs | Done |
| Join / invite / create with discovery fields | Done |
| Group chat + `senderDisplay` / `senderRole` | Done (API-first) |
| Save / Unsave (pin) | Done (`isPinned` from API + reconciled local cache) |
| Share invite `GET` (public + private) | Done (uses backend `shareUrl` / codes) |
| Share l10n + email/username invite UI | Done |
| Hub recommended empty state | Done |
| Member role PATCH (admin/member) | Done |
| Recommended cache (1 min) | Done |
| EN / AR strings (`community*` l10n keys) | Done |

## Backend gaps (send to backend team)

See **[BACKEND_COMMUNITY_API_REQUEST.md](./BACKEND_COMMUNITY_API_REQUEST.md)** — `isPinned` on memberships, public `/invite`, message sender fields.

## Related backend docs

- Discover handoff: `FLUTTER_COMMUNITY_DISCOVER_HANDOFF.md` (Downloads / shared with team)
- **Your Report** gaps (`YOUR_REPORT_BACKEND_GAPS.md`) are separate — Flutter should migrate to `FLUTTER_YOUR_REPORT_HANDOFF.md` for reports; not blocking community.

## Manual QA

See [COMMUNITY_E2E_TEST.md](./COMMUNITY_E2E_TEST.md).
