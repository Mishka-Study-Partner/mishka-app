# Chat with Mishka — AI service

The app uses **`lib/features/chat_with_mishka/data/service/mishka_ai_service.dart`** (real REST client).

Configuration: **`lib/features/chat_with_mishka/data/ai_service_config.dart`**  
Shared URLs: **`lib/core/network/mishka_ai_model_urls.dart`**

| Setting | Default |
|---------|---------|
| Production base URL | `https://mishka-ai-model-production-c459.up.railway.app` |
| Legacy ngrok (dev only) | `MishkaAiModelUrls.legacyNgrokBaseUrl` — not used unless you override |
| Local dev (port 8080) | `MishkaAiModelUrls.localDevBaseUrl` → `http://127.0.0.1:8080` |
| Override | `--dart-define=AI_BASE_URL=https://...` |
| ngrok header | `ngrok-skip-browser-warning: true` (automatic when host contains `ngrok`) |

## Timeouts

| Call | Timeout |
|------|---------|
| `POST /upload` | 3 min |
| `POST /chat` | 90 s |
| `POST /generate-tools` | 2 min |

## Verify (no model tokens)

```bash
dart tool/verify_chat_ai_api.dart
```

Manual E2E: [docs/CHAT_WITH_MISHKA_AI_E2E_TEST.md](docs/CHAT_WITH_MISHKA_AI_E2E_TEST.md)

## Local ML / offline dev

For offline UI work without the AI backend, inject a fake implementation in tests or temporarily stub `MishkaAiService` in the screen — there is no bundled dummy service in the repo anymore.
