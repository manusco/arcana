# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Accessibility for Custom Interactive Widgets
**Learning:** Custom interactive widgets built with `GestureDetector` (like the color picker) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` used for button-like interactions in `Semantics(button: true, label: ...)` to ensure accessibility.
