# Palette's Journal

## 2024-05-24 - Accessibility in Custom Widgets
**Learning:** Custom interactive widgets (like the language flags using `GestureDetector`) are invisible to screen readers as buttons unless explicitly wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` based buttons in `Semantics(button: true, label: "...")` to ensure they are navigable.

## 2024-05-24 - Mobile Input UX
**Learning:** Flutter's default `TextField` is bare-bones. Adding `TextCapitalization.words`, `AutofillHints`, and `TextInputAction` makes a simple name field feel native and "smart".
**Action:** Always configure `TextField` with these properties when asking for names.
