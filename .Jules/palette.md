## 2024-05-22 - Semantic Wrapping for Custom Widgets
**Learning:** Custom interactive widgets (like those using `GestureDetector`) are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always wrap `GestureDetector` with `Semantics` and set appropriate properties like `button: true`, `label`, and `selected`.

## 2024-05-22 - Name Input Configuration
**Learning:** Default text fields are poor for name entry. Users expect auto-capitalization and autofill support for their names.
**Action:** Always configure name inputs with `TextCapitalization.words`, `AutofillHints.name`, `TextInputType.name`, and `TextInputAction.done`.

## 2024-05-22 - Disabled State Visualization
**Learning:** `IconButton`s with explicit `color` properties on their `Icon` child do not visually change when disabled (`onPressed: null`).
**Action:** Manually manage the `Icon` color (e.g., `condition ? color : Colors.grey`) or remove the explicit color to allow the button's disabled theme to take over.
