# Our Community — manual E2E test path

Run after backend is up (`localhost:3000` or ngrok) and you are signed in.

## API smoke test (before manual UI)

From repo root (use your real password, not `…`):

```bash
chmod +x tool/verify_community_backend_fixes.sh
TEST_EMAIL=you@example.com TEST_PASSWORD=yourpassword ./tool/verify_community_backend_fixes.sh
```

Do **not** use `dart run tool/verify_community_backend_fixes.dart` from the Flutter project root — it fails with a `native_assets` / `objective_c` error. The shell script runs a standalone package under `tool/api_verify/`.

## 1. Home → Discover

- [ ] Home → **Explore communities** card opens **Discover Communities**
- [ ] Tabs **For you / Popular / New** load lists
- [ ] Subject chips filter browse list
- [ ] Search submits browse query
- [ ] **Join** on a community → lands on community home (no 404)

## 2. Our Community hub

- [ ] Category → **Our Community** loads without red error screen
- [ ] **Saved Communities** shows pinned items (after save)
- [ ] **Private / Public Communities you're in** only show memberships
- [ ] **Recommended** does not duplicate communities you already joined
- [ ] **Discover Communities** button opens discover screen
- [ ] Pull-to-refresh reloads lists

## 3. Save / Unsave

- [ ] Open a community → ⋮ → **Save Community** → appears under **Saved Communities**
- [ ] ⋮ → **Unsave Community** → removed from saved
- [ ] Home → **Rejoin saved Community** scrolls to saved section

## 4. Create community (discovery fields)

- [ ] **Create New Community** → Public → subject/purpose chips visible
- [ ] Create with name → success → community home
- [ ] New public community can appear in discover (after backend indexing)

## 5. Group chat

- [ ] Open a group → messages load
- [ ] Own messages: **Me · Owner/Admin/Member** (role from API or membership)
- [ ] Others: name · role when API sends `senderDisplay` / `senderRole`
- [ ] Send text → appears with correct label

## 6. Manage members (owner/admin)

- [ ] Community detail → **Manage Members**
- [ ] Expand member → **Make Admin** / **Make Member** updates role
- [ ] Cannot change Owner or your own role

## 7. Pin API / backend

- [ ] Save community succeeds (not 502)
- [ ] If backend down, friendly error snackbar
