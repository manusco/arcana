# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Flutter Semantics for Custom Widgets
**Learning:** `GestureDetector` based buttons (like the language selector) are invisible to screen readers without a `Semantics` wrapper. They need `button: true`, `selected: bool`, and a descriptive `label`.
**Action:** Always wrap custom tappable containers in `Semantics`.
