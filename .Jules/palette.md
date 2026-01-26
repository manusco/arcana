## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-23 - Icon Button Accessibility
**Learning:** `IconButton`s are frequently implemented without `tooltip`s, making them inaccessible to screen readers and confusing for mouse users.
**Action:** Always provide a localized `tooltip` for every `IconButton`, especially for action buttons like "+" and "-".
