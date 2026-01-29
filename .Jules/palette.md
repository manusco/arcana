## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-24 - Numeric Control Accessibility
**Learning:** Icon-only buttons used for numeric adjustments need explicit disabled states (visual + functional) and tooltips to be usable.
**Action:** Use ternary operators for color and `onPressed` to reflect state limits, and always add localized `tooltip`.
