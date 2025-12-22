# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Custom Interactive Elements Accessibility
**Learning:** Custom interactive widgets (like the color selection circles in `_colorBtn`) are completely invisible to screen readers unless explicitly wrapped in `Semantics`. `GestureDetector` alone does not provide semantic information.
**Action:** Always wrap `GestureDetector` widgets that act as buttons in `Semantics(button: true, label: '...', child: ...)` to ensure they are accessible.
