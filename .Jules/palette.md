## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-23 - IconButton Disabled State Visibility
**Learning:** When an `IconButton` contains an `Icon` with an explicit `color` property, the button will not visually appear disabled even if `onPressed` is null.
**Action:** When using explicit colors in Icons, manually manage the color state (e.g., via ternary operator) to reflect the disabled state (e.g., `condition ? Colors.amber : Colors.grey`).
