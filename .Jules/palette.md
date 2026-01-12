# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` in `Semantics` with `button: true`, a localized `label`, and proper state indicators (like `selected`) when building custom UI controls.

## 2024-05-22 - Flutter Form Input Standards
**Learning:** Default Flutter `TextField` widgets are not optimized for specific data types like names, leading to poor keyboard experiences (no capitalization, wrong layout).
**Action:** Always configure `TextField` for names with `TextCapitalization.words`, `AutofillHints.name` (requires services import), `TextInputType.name`, and `TextInputAction.done` or `next`.
