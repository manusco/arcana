## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Input Field Optimization
**Learning:** Flutter's `TextField` requires explicit `TextCapitalization`, `TextInputType`, and `AutofillHints` configuration to feel "native" and helpful on mobile. Users expect their name to be capitalized automatically.
**Action:** Always configure `TextField` with these properties for name/email inputs.

## 2024-05-22 - Custom Widget Accessibility
**Learning:** Custom interactive widgets (like the language flag toggle using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Wrap any `GestureDetector` that acts as a button with `Semantics(button: true, label: '...', selected: ...)` .
