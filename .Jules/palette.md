# Palette's Journal

## 2024-05-22 - Initial Journal Creation
**Learning:** Starting a new journal for the magic_cards project.
**Action:** Will record critical UX/a11y learnings here.

## 2024-05-22 - Text Input Usability
**Learning:** Flutter's `TextField` defaults are bare-bones. For name inputs, explicitly setting `TextCapitalization.words`, `AutofillHints.name`, and `TextInputType.name` significantly reduces friction on mobile keyboards.
**Action:** Always configure `TextField` properties based on the expected content type, not just the decoration.
