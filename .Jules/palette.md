## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-23 - Icon-Only Button Accessibility
**Learning:** Icon-only buttons (like `IconButton`) are often added without tooltips, making them inaccessible to screen readers and unclear on hover.
**Action:** Always verify `IconButton` widgets have a localized `tooltip` property defined.

## 2024-05-23 - Dialog Input Focus
**Learning:** Users expect to type immediately when a dialog with a primary input field (like name entry) opens.
**Action:** Always set `autofocus: true` on the primary `TextField` or `TextFormField` within a modal dialog.
