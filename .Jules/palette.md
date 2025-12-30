# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Flutter Input Accessibility
**Learning:** Flutter's `TextField` requires explicit `autofillHints`, `keyboardType`, and `textCapitalization` to provide a native-feeling experience on mobile. Simply having a label is not enough for modern UX standards.
**Action:** Always configure these properties for user input fields. Also, `IconButton`s are inaccessible by default without a `tooltip` or `semanticLabel`.
