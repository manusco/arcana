## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-10-24 - Modal Dialog Input Focus
**Learning:** Users expect the primary input in a modal dialog to be ready for typing immediately. Requiring an extra tap/click to focus adds unnecessary friction.
**Action:** Always set `autofocus: true` on the primary `TextField` or `TextFormField` within a modal dialog (e.g., in `showDialog` or `showModalBottomSheet`).
