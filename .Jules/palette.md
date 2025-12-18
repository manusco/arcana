## 2024-05-22 - Accessibility for Custom Toggles
**Learning:** Custom selection widgets (like the language flags) using `GestureDetector` are invisible to screen readers without `Semantics`.
**Action:** Always wrap custom interactive elements in `Semantics(button: true, selected: bool, label: ...)` to ensure state and role are announced.
