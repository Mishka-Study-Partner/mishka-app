# Quick Service Switching Guide

## Current Setup
The app is currently configured to use the **Dummy AI Service** for testing and development.

---

## TO USE DUMMY SERVICE (Current Setup) ✅

### File to Check
`lib/features/chat_with_mishka/presentation/screens/chat_with_mishka_screen.dart`

### Current Import
```dart
import '../../data/service/mishka_dummy_ai_service.dart' as ai_service;
```

### Current Usage
```dart
@override
void initState() {
  super.initState();
  controller = ChatFlowController();
  ai = ai_service.MishkaAiService(
    baseUrl: 'http://127.0.0.1:8000', // Ignored in dummy service
  );
}
```

**No changes needed!** The app is ready to test with dummy data.

---

## TO SWITCH TO REAL AI SERVICE (Backend)

### Step 1: Change Import
In `chat_with_mishka_screen.dart`, change:
```dart
// FROM:
import '../../data/service/mishka_dummy_ai_service.dart' as ai_service;

// TO:
import '../../data/service/mishka_ai_service.dart' as ai_service;
```

### Step 2: Update Backend URL (if needed)
```dart
@override
void initState() {
  super.initState();
  controller = ChatFlowController();
  ai = ai_service.MishkaAiService(
    baseUrl: 'http://YOUR_SERVER_IP:8000', // Update with real backend URL
  );
}
```

### Step 3: Test
- Run the app
- Upload a PDF
- Select difficulty
- Everything should work exactly the same!

---

## Why Zero UI Changes?

Both services implement the **exact same interface**:

```dart
class MishkaAiService {
  // Same signature in both services
  Future<ExplainResult> explainPdf({
    required String pdfPath,
    required String summaryLevel,
  }) async { ... }

  Future<String> chat({
    required String sessionId,
    required String message,
  }) async { ... }

  Future<Map<String, dynamic>> generateTool({
    required String sessionId,
    required StudyAction action,
    required String complexity,
  }) async { ... }
}
```

**The UI never directly calls the service** - it only uses these 3 methods. As long as both services implement the same interface, they're plug-and-play compatible!

---

## Service Differences

### Dummy Service
- ✅ No network calls (instant/simulated delay)
- ✅ Hardcoded responses
- ✅ Perfect for UI testing
- ✅ Always returns stable data
- ✅ No backend required

### Real Service  
- 🔌 Makes HTTP requests to backend
- 📝 Processes actual PDF files
- 🤖 Uses real AI models
- 🔐 Requires backend server running
- 🌍 Needs valid backend URL

---

## File Locations

| Component | Location |
|-----------|----------|
| Dummy Service | `lib/features/chat_with_mishka/data/service/mishka_dummy_ai_service.dart` |
| Real Service | `lib/features/chat_with_mishka/data/service/mishka_ai_service.dart` |
| Chat Screen | `lib/features/chat_with_mishka/presentation/screens/chat_with_mishka_screen.dart` |
| Chat UI | `lib/features/chat_with_mishka/presentation/widgets/chat_message_render.dart` |
| Tool Preview | `lib/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart` |
| Controller | `lib/features/chat_with_mishka/data/controller/chat_flow_controller.dart` |

---

## Testing Dummy Service

### Expected Behavior

**PDF Upload Flow:**
1. User uploads PDF → Shows in chat ✓
2. User selects difficulty (Simple/Intermediate/Advanced) ✓
3. System shows "Analyzing PDF..." ✓
4. Receives dummy explanation (1-2 sec delay) ✓
5. Shows options: Quiz / Flashcards / Mind Map ✓

**Quiz Flow:**
1. User selects "Quiz" ✓
2. Shows: "Question 1/10" ✓
3. Shows 4 answer options ✓
4. User submits answer ✓
5. Shows: Green (correct) or Red (incorrect) with cat image ✓
6. Shows: Next/Prev buttons to navigate ✓

**Flashcards Flow:**
1. User selects "Flashcards" ✓
2. Shows: 4 cards in horizontal scroll ✓
3. Each card shows: image, title, flip indicator ✓

**Chat Flow:**
1. User can chat with Mishka after explanation ✓
2. Mishka replies with deterministic responses ✓
3. All messages show in chat with proper styling ✓

---

## Troubleshooting

### Issue: Import Error
**Error:** `Cannot find package 'mishka_dummy_ai_service'`

**Solution:**
- Verify file exists: `data/service/mishka_dummy_ai_service.dart`
- Check import path uses correct file name
- Run `flutter pub get`

### Issue: Quiz showing 0 questions
**Error:** Questions list is empty

**Solution:**
- Dummy service always returns 10 questions
- Check `toolData['questions']` is not null
- Verify `ToolPreviewRenderer` is receiving data

### Issue: Images not showing
**Error:** Cat images missing or asset errors

**Solution:**
- Images fallback to emoji automatically
- Verify assets in `pubspec.yaml`:
  ```yaml
  flutter:
    assets:
      - assets/images/
  ```
- Check image files exist in `assets/images/`

### Issue: Need to create new service variant?

**Template:**
```dart
import '../controller/chat_flow_controller.dart';

class ExplainResult {
  final String sessionId;
  final String explanation;
  ExplainResult({required this.sessionId, required this.explanation});
}

class MishkaAiService {
  final String baseUrl;
  MishkaAiService({this.baseUrl = 'http://127.0.0.1:8000'});

  Future<ExplainResult> explainPdf({
    required String pdfPath,
    required String summaryLevel,
  }) async {
    // Your implementation
  }

  Future<String> chat({
    required String sessionId,
    required String message,
  }) async {
    // Your implementation
  }

  Future<Map<String, dynamic>> generateTool({
    required String sessionId,
    required StudyAction action,
    required String complexity,
  }) async {
    // Your implementation
  }
}
```

Then import it in the screen and you're done!

---

## Summary

✅ **Implementation Complete**
- Dummy service ready for testing
- Chat UI displays quiz/flashcards inline
- Green/red answer feedback with cat images
- Zero UI changes to switch services
- All data contracts match exactly

📝 **To switch**: Change 1 import line in `chat_with_mishka_screen.dart`

🎉 **Ready to test!**


