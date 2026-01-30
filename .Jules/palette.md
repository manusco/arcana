## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2026-01-09 - IconButton Disabled State Visibility
**Learning:** When an `IconButton` contains an `Icon` with an explicit `color` property, the button does not visually appear disabled (greyed out) even when `onPressed` is null.
**Action:** Manually manage the `Icon` color using a ternary operator based on the disabled state (e.g., `color: isEnabled ? Colors.amber : Colors.grey`).
