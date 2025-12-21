# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Accessibility & Localization
**Learning:** Flutter `Semantics` widget is crucial for custom interactive elements (like `GestureDetector`) that aren't native buttons. Without it, screen readers miss the "button" trait and label.
**Action:** Always wrap `GestureDetector` based buttons in `Semantics(button: true, label: "...")`.

**Learning:** `IconButton` tooltips should be localized and reactive. Using `context.read` for localization strings prevents them from updating when language changes.
**Action:** Use `context.watch<LocalizationService>()` for all UI strings, including tooltips and semantic labels.
