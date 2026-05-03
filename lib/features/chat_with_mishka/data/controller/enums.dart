enum ChatStep {
  greeting,
  waitingForPdf,
  waitingForDifficulty,
  explaining,
  waitingForAction,
  freeInteraction,
}

enum DifficultyLevel { simple, intermediate, hard }

enum StudyAction { quiz, flashcards, mindmap }

enum MessageType {
  system,
  file,
  options,
  selection,
  explanation,
}
