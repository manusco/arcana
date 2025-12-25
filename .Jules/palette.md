# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Name Input Optimization
**Learning:** Flutter's `TextField` requires explicit `autofillHints`, `keyboardType`, and `textCapitalization` to feel "native" for name entry. Users expect their name to auto-capitalize and be suggestible by the OS.
**Action:** Always configure `TextField` for personal information with `AutofillHints` and `TextCapitalization`.
