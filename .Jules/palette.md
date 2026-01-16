## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2025-05-24 - IconButton Disabled State Colors
**Learning:** When an `Icon` inside an `IconButton` has an explicit color, setting `onPressed: null` disables interaction but doesn't grey out the icon automatically.
**Action:** Manually toggle the `Icon` color (e.g., using a ternary operator) based on the disabled state to ensure visual feedback.
