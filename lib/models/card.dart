import 'enums.dart';

class Card {
  final CardType type;
  final CardColor color;
  final int value; // 1-13 for NUMBER, 0 for SHADOW, 14 for ARCANUM (internal logic helper)
  final String id;
  final String imageAssetPath;

  Card({
    required this.type,
    required this.color,
    this.value = 0,
    required this.id,
    required this.imageAssetPath,
  });

  bool isTrump(CardColor? trumpColor) {
    if (type == CardType.ARCANUM) return false; // Arcanums are not "trump suit", they are super-trump
    if (type == CardType.SHADOW) return false;
    return color == trumpColor;
  }

  // Returns true if 'this' card beats the 'other' card.
  // 'other' is typically the current winning card of the trick.
  bool beats(Card other, CardColor? trumpColor, CardColor? leadColor) {
    // 1. Arcanums
    if (other.type == CardType.ARCANUM) return false; // First Arcanum wins, so nothing beats it
    if (this.type == CardType.ARCANUM) return true; // This is Arcanum, other is not, so this wins

    // 2. Trumps
    bool thisIsTrump = this.isTrump(trumpColor);
    bool otherIsTrump = other.isTrump(trumpColor);

    if (otherIsTrump) {
      if (!thisIsTrump) return false;
      // Both are trump: higher value wins
      return this.value > other.value;
    }
    if (thisIsTrump) return true; // This is trump, other is not

    // 3. Lead Color
    // If we are here, neither is Wizard or Trump (or other is not Trump)
    bool otherIsLead = other.color == leadColor && other.type == CardType.NUMBER;
    bool thisIsLead = this.color == leadColor && this.type == CardType.NUMBER;

    if (otherIsLead) {
      if (!thisIsLead) return false;
      // Both are lead color: higher value wins
      return this.value > other.value;
    }
    if (thisIsLead) return true;

    // 4. Shadows and Off-suit non-trumps
    // If other is Shadow, almost anything beats it (except another Shadow played later)
    if (other.type == CardType.SHADOW) {
       if (this.type == CardType.SHADOW) return false; // First Shadow wins against subsequent Shadows
       return true; // Any non-Shadow beats a Shadow (if Shadow was leading/winning)
    }

    // If we are here, both are off-suit non-trumps and non-wizards.
    // Usually this means 'this' was thrown away (sloughed), so it doesn't beat 'other'.
    // Unless 'other' was also sloughed? But 'other' is the current winner.
    // The current winner must be either Wizard, Trump, Lead, or the first Jester.
    // If 'other' is just a high card of a non-lead suit, it shouldn't be winning unless it was led?
    // If 'other' was led (and is not Jester), then 'otherIsLead' would be true.
    
    return false;
  }

  @override
  String toString() {
    if (type == CardType.ARCANUM) return 'A';
    if (type == CardType.SHADOW) return 'S';
    return '${color.name.substring(0, 1)}$value';
  }
}
