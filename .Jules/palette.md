## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-24 - IconButton Disabled State
**Learning:** `IconButton` does not automatically dim its icon when disabled unless the color is defined on the button itself, not the icon.
**Action:** Set `color` and `disabledColor` on the `IconButton` widget, not the child `Icon`, and set `onPressed: null` to disable.
