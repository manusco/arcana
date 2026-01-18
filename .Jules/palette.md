## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-23 - IconButton Disabled State Visibility
**Learning:** `IconButton` does not automatically dim its child `Icon` when disabled (`onPressed: null`) if the `Icon` has an explicit `color` property.
**Action:** When using colored icons in buttons, manually handle the color state (e.g., `color: isEnabled ? Colors.amber : Colors.grey`) to ensure the disabled state is visually apparent.
