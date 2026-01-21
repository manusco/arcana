## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-24 - IconButton Disabled State Visibility
**Learning:** Flutter's `IconButton` does not automatically dim the icon if the child `Icon` has an explicit `color` property, even when `onPressed` is null.
**Action:** When using colored icons in buttons, manually toggle the color based on state (e.g., `color: isEnabled ? Colors.amber : Colors.grey`) to ensure the disabled state is visually apparent.
