# PROJECT STRUCTURE - POST IMPLEMENTATION

## Chat with Mishka Feature

```
lib/features/chat_with_mishka/
│
├── data/
│   ├── controller/
│   │   ├── chat_flow_controller.dart ✏️ MODIFIED
│   │   │   └── Now includes:
│   │   │       - ChatMessage (unified, with isFromMishka, time, toolData)
│   │   │       - MessageType enum (+ toolPreview)
│   │   │       - ChatFlowController (+ sessionId, onUserChatMessage, etc)
│   │   │
│   │   └── enums.dart (unchanged)
│   │
│   ├── model/
│   │   ├── flaahcard_model.dart (unchanged)
│   │   ├── uploaded_item.dart (unchanged)
│   │   └── explaination_result.dart (unchanged)
│   │   │   ❌ Deleted: chat_model.dart (consolidated into controller)
│   │
│   └── service/
│       ├── mishka_ai_service.dart ✅ (Real service - unchanged)
│       ├── mishka_dummy_ai_service.dart ✨ NEW
│       │   └── MishkaAiService (dummy implementation)
│       │       - explainPdf() → Returns ExplainResult
│       │       - chat() → Returns deterministic String
│       │       - generateTool() → Returns Map with quiz/flashcards/mindmap
│       │
│       └── demo_ai_Service.dart (left for reference)
│       │   ❌ Deleted: mishka_ai_service_dummy.dart (old version)
│
└── presentation/
    ├── screens/
    │   ├── chat_with_mishka_screen.dart ✏️ MODIFIED
    │   │   └── Now:
    │   │       - Imports mishka_dummy_ai_service
    │   │       - Adds tool data to chat (not navigate)
    │   │       - Calls controller.onToolPreviewGenerated()
    │   │
    │   ├── flashcards_screen.dart (unchanged - may be deprecated)
    │   ├── quiz_screen.dart (unchanged - may be deprecated)
    │   └── mindmap_screen.dart (unchanged - may be deprecated)
    │
    └── widgets/
        ├── chat_message_render.dart ✏️ MODIFIED
        │   └── Now includes:
        │       - Case for MessageType.toolPreview
        │       - Imports tool_preview_renderer
        │       - Renders ToolPreviewRenderer widget
        │
        ├── tool_preview_renderer.dart ✨ NEW
        │   └── ToolPreviewRenderer (StatefulWidget)
        │       - _buildFlashcardsPreview() → Horizontal list
        │       - _buildQuizPreview() → Question + options + answers
        │       - _buildMindmapPreview() → Compact overview
        │       - _buildHappyCat() / _buildSadCat() → Answer feedback
        │
        ├── chat_bubble.dart (unchanged)
        ├── chat_input_bar.dart (unchanged)
        ├── upload_option_menu.dart (unchanged)
        └── uploaded_file_card.dart (unchanged)
```

## Flow Diagram

```
┌─ User Opens Chat ──────────────────────────────────────┐
│                                                          │
├─ Step 1: Upload PDF                                     │
│   └─ ChatFlowController.onPdfUploaded()                │
│      └─ Add: FILE message + OPTIONS message            │
│         └─ Chat shows file + [Simple/Intermediate/Adv] │
│                                                          │
├─ Step 2: Select Difficulty                             │
│   └─ ChatFlowController.onDifficultySelected()         │
│      └─ Add: SELECTION message + SYSTEM "Analyzing.." │
│         └─ Chat shows selection + loading msg          │
│         └─ Call ai.explainPdf()                       │
│            └─ Dummy: Returns explanation in 1.2s      │
│            └─ Real: Makes HTTP POST /upload            │
│                                                          │
├─ Step 3: Show Explanation                              │
│   └─ ChatFlowController.onExplanationReady()           │
│      └─ Stores sessionId                              │
│      └─ Add: EXPLANATION message + OPTIONS message    │
│         └─ Chat shows text + [Quiz/Flashcards/MindMap]│
│                                                          │
├─ Step 4: Select Study Tool                             │
│   └─ ChatFlowController.onActionSelected()             │
│      └─ Add: SELECTION message                        │
│      └─ Call ai.generateTool(sessionId, action, level)│
│         └─ Dummy: Returns quiz/flashcards in 1s       │
│         └─ Real: Makes HTTP POST /generate-tools       │
│                                                          │
├─ Step 5: Show Tool Preview in Chat                     │
│   └─ ChatFlowController.onToolPreviewGenerated()       │
│      └─ Add: TOOLPREVIEW message with toolData        │
│         └─ ToolPreviewRenderer renders:               │
│            ├─ Quiz: Question 1/10 + 4 options         │
│            │  └─ Submit → Green✓/Red✗ + Cat image    │
│            │  └─ Next/Prev to navigate                │
│            ├─ Flashcards: 4-item horizontal list      │
│            │  └─ Each shows image + title + flip icon │
│            └─ MindMap: Root + node count              │
│                                                          │
└─ Step 6: Continue Chat (Optional)                      │
    └─ User types message                                 │
       └─ ChatFlowController.onUserChatMessage()         │
          └─ Add: TEXT message (user)                    │
          └─ Call ai.chat(sessionId, message)           │
             └─ Dummy: Returns static response          │
             └─ Real: Makes HTTP POST /chat              │
          └─ ChatFlowController.onMishkaChatReply()      │
             └─ Add: TEXT message (Mishka)              │
```

## Message Flow

```
ChatMessage Types in Chat:

1. FILE
   - isFromMishka: false (user uploaded)
   - text: null
   - fileName: "document.pdf"
   └─ Rendered as: Right-aligned file bubble

2. OPTIONS
   - isFromMishka: true (system asks)
   - text: null
   - options: ["Simple", "Intermediate", "Advanced"]
   └─ Rendered as: Column of option buttons

3. SELECTION
   - isFromMishka: false (user chose)
   - text: null
   - selectedOption: "Simple"
   └─ Rendered as: Left-aligned dark bubble with user choice

4. SYSTEM
   - isFromMishka: true (system message)
   - text: "Analyzing PDF..."
   - others: null
   └─ Rendered as: Centered gray text

5. EXPLANATION
   - isFromMishka: true (Mishka speaks)
   - text: "📚 Study Guide..."
   - others: null
   └─ Rendered as: Left-aligned white bubble with border

6. TEXT (Chat Messages)
   - isFromMishka: true/false (who speaks)
   - text: "Hello! How can I help?"
   - others: null
   └─ Rendered as: Aligned bubble (left if Mishka, right if user)

7. TOOLPREVIEW ✨ NEW
   - isFromMishka: true (system feature)
   - text: null
   - toolData: {tool_type, questions/cards/nodes, ...}
   └─ Rendered as: ToolPreviewRenderer widget
      ├─ Quiz: Interactive question with answer feedback
      ├─ Flashcards: Horizontal card list
      └─ MindMap: Tree structure preview
```

## Service Interface (Both match exactly)

```dart
abstract class IAiService {
  Future<ExplainResult> explainPdf({
    required String pdfPath,
    required String summaryLevel,
  });

  Future<String> chat({
    required String sessionId,
    required String message,
  });

  Future<Map<String, dynamic>> generateTool({
    required String sessionId,
    required StudyAction action,
    required String complexity,
  });
}
```

Implemented by:
- ✅ `MishkaAiService` (real, in mishka_ai_service.dart)
- ✅ `MishkaAiService` (dummy, in mishka_dummy_ai_service.dart)

## Data Models

```
ExplainResult
├── sessionId: String
└── explanation: String

StudyAction enum
├── quiz
├── flashcards
└── mindmap

DifficultyLevel enum
├── simple
├── intermediate
└── advanced

MessageType enum
├── system
├── text
├── explanation
├── file
├── options
├── selection
└── toolPreview ✨

ChatMessage
├── isFromMishka: bool
├── type: MessageType
├── time: DateTime
├── text: String?
├── fileName: String?
├── options: List<String>?
├── selectedOption: String?
└── toolData: Map? ✨

ChatFlowController
├── step: ChatStep
├── uploadedPdfName: String?
├── difficulty: DifficultyLevel?
├── sessionId: String? ✨
├── messages: List<ChatMessage>
├── isTypingEnabled: bool ✨
├── onPdfUploaded()
├── onDifficultySelected()
├── onExplanationReady() ✨ (with sessionId param)
├── onActionSelected()
├── onUserChatMessage() ✨
├── onMishkaChatReply() ✨
└── onToolPreviewGenerated() ✨
```

## Import Dependencies

```
chat_with_mishka_screen.dart
├── imports mishka_dummy_ai_service (currently)
│   └── Can swap to mishka_ai_service (1-line change)
├── imports ChatFlowController
├── imports ChatMessage, MessageType, StudyAction, etc.
└── creates ChatMessageRenderer for each message

chat_message_render.dart
├── imports ToolPreviewRenderer (new)
├── receives ChatMessage
├── switches on message.type
│   ├── SYSTEM → _SystemBubble
│   ├── TEXT → _TextBubble
│   ├── EXPLANATION → _TextBubble
│   ├── FILE → _FileBubble
│   ├── OPTIONS → _OptionsBubble
│   ├── SELECTION → _SelectionBubble
│   └── TOOLPREVIEW → ToolPreviewRenderer ✨
└── calls onOptionSelected callback

tool_preview_renderer.dart
├── StatefulWidget with internal state
│   ├── currentQuestionIndex
│   ├── selectedAnswerIndex
│   └── answered
├── receives toolData: Map
├── Switches on tool_type:
│   ├── "flashcards" → Horizontal list
│   ├── "quizzes" → Question flow
│   └── "mind_maps" → Tree view
└── Shows cat images on answer
    ├── Happy (correct) → mishka_happy.png
    └── Sad (incorrect) → mishka_sad.png
```

## Assets Used

```
assets/images/
├── mishka_happy.png ✅ (used for correct answers - GREEN)
├── mishka_sad.png ✅ (used for incorrect answers - RED)
├── flashcard_item1.png ✅ (flashcard preview)
├── flashcard_item2.png ✅
├── flashcard_item3.png ✅
└── saved_card_1.png ✅
```

All required assets exist and are properly referenced!

---

## Testing Scenarios

### Scenario 1: Quiz Flow
```
User sees: Question 1/10 - "What is X?"
         [Option A] [Option B] [Option C] [Option D]
         [Submit Answer]

User clicks: Option B
Result:     GREEN background ✓ + Happy cat 😊
Next step:  [Prev] [Next] buttons to navigate

Or:         RED background ✗ + Sad cat 😢
```

### Scenario 2: Flashcards Flow
```
User sees: Horizontal scrollable list of 4 cards
          [Card 1] [Card 2] [Card 3] [Card 4] →
           
Each card shows:
- Image (e.g., photo of studying)
- Title: "Understanding Core Concepts"
- Flip icon indicator
```

### Scenario 3: Chat Flow
```
User:    "What is metacognition?"
Mishka:  "Metacognition is thinking about..."
         [Options for follow-up tools]
```

---

**Ready to test! 🚀**


