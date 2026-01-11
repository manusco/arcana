# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` in `Semantics` with `button: true`, a localized `label`, and proper state indicators (like `selected`) when building custom UI controls.

## 2026-01-09 - Smart Input Configuration
**Learning:** Configuring TextFields with `autofillHints`, `textCapitalization`, and `textInputAction` significantly improves the mobile data entry experience by reducing keystrokes and context switching.
**Action:** Always configure text inputs with appropriate metadata, even for simple fields like names.
