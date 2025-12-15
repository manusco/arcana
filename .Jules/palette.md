## 2024-10-24 - Accessibility for Icon Buttons
**Learning:** Icon-only buttons (like `IconButton`) in Flutter are inaccessible to screen readers and lack hover context without a `tooltip`.
**Action:** Always add a localized `tooltip` property to `IconButton` widgets. This serves as both the visual tooltip and the semantic label for accessibility tools.

## 2024-10-24 - Consistency in Variable Usage
**Learning:** When using Provider for state management, ensure that variables like `loc` (for LocalizationService) are either defined in the current scope or accessed directly via `context.watch/read` to avoid compilation errors during refactoring.
**Action:** Prefer `context.watch<Service>()` directly in the widget tree for clarity unless a local variable is consistently available and used.
