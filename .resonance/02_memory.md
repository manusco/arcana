# Memory Log

## 2026-01-09 - Resonance Initialized
- Framework setup complete
- 16 specialist roles downloaded

## 2026-01-09 - Quality Assurance Audit Completed
- Identified critical lack of validation for insufficient cards in `GameService.startRound()`.
- Discovered null-safety risk with `trumpColor` when an Arcanum is the trump card.
- Noted fragility of the "dummy card" magic string pattern in `AiService`.
- Confirmed Flutter project has 100% test pass rate for existing unit tests.
- Lessons: Use explicit state machine guards when waiting for user input (like trump color selection) to prevent logic races.
- Lesson: Magic numbers in AI heuristics should be extracted to constants for maintainability.
- Reference: Detailed report at `docs/reports/QA-2026-01-09.md`.

## 2026-01-09 - Critical QA Fixes Implemented
- Fixed QA-01: Added deck size validation to `GameService.startRound()`.
- Fixed QA-02: Added state guards in `isValidMove` and `playCard` for null trump color.
- Fixed QA-03: Refactored `AiService` to use `Card.dummy()` and `isDummy` getter instead of magic strings.
- Implementation confirmed with Ralph Loop reproduction scripts.

## 2026-01-09 - PR 9 Merged (Accessibility & Animations)
- Feature: Added `Semantics` to `CardWidget` and game controls for better screen reader support.
- Feature: Added interactive animations to cards using `flutter_animate`.
- Fix: Successfully resolved conflicts between PR changes and local stashed work (lint fixes).
- Lesson: `flutter_animate` entry animations in tests require `await tester.pumpAndSettle()` to avoid "Timer still pending" errors.
- Lesson: Adding new services like `LocalizationService` to core widgets requires updating all associated widget tests to provide the service via `ChangeNotifierProvider`.

## 2026-01-09 - Performance Optimization & Test Expansion
- Implemented memoization in `AiService` for `_cardStrength` and `_calculateWinProbability`.
- Result: Reduced redundant iterations during bidding and decision making.
- Added 8 new tests:
  - `test/ai_strategy_test.dart`: Strategy validation for bots.
  - `test/card_widget_test.dart`: UI rendering validation for `CardWidget`.
- Total test suite now stands at 13 tests, all passing.
- Lesson: Widget tests involving animations require `pumpAndSettle()` to handle pending timers.
- Lesson: Provider dependencies in widgets must be explicitly mocked/provided in `testWidgets`.
