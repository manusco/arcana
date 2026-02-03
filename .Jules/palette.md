## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-23 - IconButton Disabled State
**Learning:** `IconButton` does not automatically dim its icon when disabled if the `Icon` widget has an explicit `color` set.
**Action:** Move the `color` property from the `Icon` widget to the `IconButton` widget to allow `disabledColor` to take effect when `onPressed` is null.
