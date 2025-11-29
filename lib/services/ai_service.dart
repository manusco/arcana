import 'dart:math';
import '../models/card.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/player.dart';

class AiService {
  final Random _random = Random();

  // Probability-based Bidding
  int calculateBid(Player player, GameState gameState) {
    double expectedTricks = 0.0;
    CardColor? trumpColor = gameState.trumpColor;
    int totalPlayers = gameState.players.length;
    int cardsInHand = player.hand.length;
    
    // Estimate strength of each card
    for (var card in player.hand) {
      double winProbability = _calculateWinProbability(card, player.hand, gameState);
      expectedTricks += winProbability;
    }

    // Adjust for risk tolerance
    if (player is BotPlayer) {
      // Risk factor shifts the "rounding point".
      // Standard round: 2.5 -> 3.0.
      // Cautious (-0.5): 2.5 -> 2.0 (needs 3.0 to bid 3).
      // Risky (+0.5): 2.0 -> 3.0 (needs only 2.0 to bid 3... wait, no).
      
      // Better logic: Add risk factor to expected tricks before rounding?
      // Expected: 2.4. Risk +0.2 -> 2.6 -> Bids 3.
      // Expected: 2.6. Risk -0.2 -> 2.4 -> Bids 2.
      return (expectedTricks + player.riskFactor).round();
    }
    
    return expectedTricks.round();
  }

  double _calculateWinProbability(Card card, List<Card> hand, GameState gameState) {
    // 1. Wizards are almost 100% win, unless played late in a trick with another Wizard.
    // But in bidding, we assume we can play it strategically.
    if (card.type == CardType.ARCANUM) return 1.0;
    
    // 2. Shadows are 0% win.
    if (card.type == CardType.SHADOW) return 0.0;

    int totalPlayers = gameState.players.length;
    CardColor? trumpColor = gameState.trumpColor;
    
    // 3. Trumps
    if (card.isTrump(trumpColor)) {
      // Probability depends on value and how many trumps are out there.
      // Simple model: (Value / 13) * (Strength factor)
      // High trumps (11, 12, 13) are very strong.
      // Low trumps (1-5) are weak if over-trumped, but strong if led or sloughed.
      
      // If I have the Ace of Trumps (13), prob is 1.0 (unless Wizard).
      // If I have 1 of Trumps, prob is low, maybe 0.2?
      
      // Let's use a linear scale: 0.3 + (value/13 * 0.7)
      // 13 -> 1.0
      // 1 -> 0.35
      return 0.3 + (card.value / 13.0) * 0.7;
    }

    // 4. Non-Trumps (Off-suit)
    // Probability depends on:
    // a) Is it high? (A, K, Q)
    // b) Is the suit "long" or "short" in my hand?
    //    If I have many cards of this suit, others might be void and trump me.
    //    If I have few, I might be void later (good for me to trump, bad for this card to win).
    
    // Base probability for high cards:
    // A (13) -> 0.8 (risk of being trumped or Wizard)
    // K (12) -> 0.6
    // Q (11) -> 0.4
    // Lower -> < 0.1
    
    double baseProb = 0.0;
    if (card.value == 13) baseProb = 0.8;
    else if (card.value == 12) baseProb = 0.6;
    else if (card.value == 11) baseProb = 0.4;
    else if (card.value >= 8) baseProb = 0.2;
    
    // Adjust by suit length in hand (more cards = higher risk of others being void)
    int suitCount = hand.where((c) => c.color == card.color && c.type == CardType.NUMBER).length;
    // If I have 5 cards of Red, likely someone else has none.
    // Penalty factor: 1.0 - (suitCount * 0.1)
    double penalty = 1.0 - ((suitCount - 1) * 0.1);
    if (penalty < 0.1) penalty = 0.1;
    
    return baseProb * penalty;
  }

  // Heuristic Play with "Smart" choices
  Card chooseCardToPlay(Player player, GameState gameState) {
    List<Card> validCards = player.hand.where((c) => _isValidMove(c, player, gameState)).toList();
    if (validCards.isEmpty) return player.hand.first;

    bool wantToWin = player.wonTricks < player.predictedTricks;
    bool mustLose = player.wonTricks > player.predictedTricks; // Already overbid
    
    // If we are exactly on target, we want to lose (usually safer to stay on target).
    // Unless it's the last trick and we need 0 more? No, if won == predicted, we want 0 more.
    // So wantToWin is ONLY true if won < predicted.
    
    if (wantToWin) {
      return _tryToWin(validCards, gameState);
    } else {
      return _tryToLose(validCards, gameState);
    }
  }

  Card _tryToWin(List<Card> validCards, GameState gameState) {
    // 2. If trick is empty (I lead):
    if (gameState.currentTrick.isEmpty) {
      // Don't waste Arcanum on leading unless we have no other good options
      // Try to lead with high cards first
      var nonArcanums = validCards.where((c) => c.type != CardType.ARCANUM).toList();
      if (nonArcanums.isNotEmpty) {
        nonArcanums.sort((a, b) => _cardStrength(b, gameState).compareTo(_cardStrength(a, gameState)));
        // Lead with highest non-Arcanum (Ace/King or high trump)
        return nonArcanums.first;
      }
      // Only lead Arcanum if we have nothing else
      return validCards.first;
    }

    // 3. If trick exists, check current winner
    Card currentWinner = _getCurrentWinner(gameState);
    
    // Check if an Arcanum was already played
    bool arcanumAlreadyPlayed = gameState.currentTrick.any((pc) => pc.card.type == CardType.ARCANUM);
    
    // Filter cards that beat the current winner (excluding Arcanum for now)
    var nonArcanumWinners = validCards
        .where((c) => c.type != CardType.ARCANUM && c.beats(currentWinner, gameState.trumpColor, gameState.leadColor))
        .toList();
    
    if (nonArcanumWinners.isNotEmpty) {
      // We can win without Arcanum! Play the cheapest winning card
      nonArcanumWinners.sort((a, b) => _cardStrength(a, gameState).compareTo(_cardStrength(b, gameState)));
      return nonArcanumWinners.first; // Cheapest winner
    }
    
    // Can't win with regular cards. Should we play Arcanum?
    var arcanum = validCards.firstWhere((c) => c.type == CardType.ARCANUM, orElse: () => _dummy());
    
    if (arcanum.id != "dummy") {
      // Only play Arcanum if:
      // 1. No Arcanum was already played (we'd tie/lose), OR
      // 2. We're last to play (guaranteed win)
      int playersLeft = gameState.players.length - gameState.currentTrick.length - 1;
      
      if (!arcanumAlreadyPlayed || playersLeft == 0) {
        return arcanum;
      }
      // Arcanum already played and we're not last - don't waste it
    }
    
    // Cannot win. Slough lowest card
    return _sloughCard(validCards, gameState);
  }

  Card _tryToLose(List<Card> validCards, GameState gameState) {
    // 1. Play Shadow if available (guaranteed lose usually).
    var shadow = validCards.firstWhere((c) => c.type == CardType.SHADOW, orElse: () => _dummy());
    if (shadow.id != "dummy") return shadow;

    // 2. If trick is empty (I lead):
    if (gameState.currentTrick.isEmpty) {
      // Lead lowest card (non-trump preferably).
      validCards.sort((a, b) => _cardStrength(a, gameState).compareTo(_cardStrength(b, gameState)));
      return validCards.first;
    }

    // 3. If trick exists:
    // Try NOT to beat the current winner.
    Card currentWinner = _getCurrentWinner(gameState);
    
    // Filter cards that DO NOT beat the winner
    var losingCards = validCards.where((c) => !c.beats(currentWinner, gameState.trumpColor, gameState.leadColor)).toList();
    
    if (losingCards.isNotEmpty) {
      // Play highest losing card? (To get rid of high cards)
      // OR play lowest to be safe?
      // "Duck": Play highest card that is still lower than winner (if following suit).
      // "Slough": Play high off-suit card.
      
      // Sort by strength descending (get rid of dangerous cards)
      losingCards.sort((a, b) => _cardStrength(b, gameState).compareTo(_cardStrength(a, gameState)));
      return losingCards.first;
    } else {
      // Must win (forced). Play lowest winning card.
      validCards.sort((a, b) => _cardStrength(a, gameState).compareTo(_cardStrength(b, gameState)));
      return validCards.first;
    }
  }

  Card _sloughCard(List<Card> validCards, GameState gameState) {
    // Get rid of dangerous cards (high non-trumps) or just low cards?
    // If we want to win LATER, keep high cards.
    // If we failed to win this trick, we might want to keep high trumps for later.
    // Throw away low off-suit.
    validCards.sort((a, b) => _cardStrength(a, gameState).compareTo(_cardStrength(b, gameState)));
    return validCards.first;
  }

  double _cardStrength(Card c, GameState gameState) {
    if (c.type == CardType.ARCANUM) return 100;
    if (c.type == CardType.SHADOW) return -1;
    if (c.isTrump(gameState.trumpColor)) return 20 + c.value.toDouble();
    if (c.type == CardType.NUMBER) return c.value.toDouble();
    return 0;
  }

  Card _getCurrentWinner(GameState gameState) {
    if (gameState.currentTrick.isEmpty) return _dummy();
    
    var winner = gameState.currentTrick[0].card;
    for (int i = 1; i < gameState.currentTrick.length; i++) {
      var challenger = gameState.currentTrick[i].card;
      if (challenger.beats(winner, gameState.trumpColor, gameState.leadColor)) {
        winner = challenger;
      }
    }
    return winner;
  }

  Card _dummy() => Card(type: CardType.NUMBER, color: CardColor.NONE, id: "dummy", imageAssetPath: "");

  bool _isValidMove(Card card, Player player, GameState gameState) {
    if (gameState.currentTrick.isEmpty) return true;
    if (card.type == CardType.ARCANUM || card.type == CardType.SHADOW) return true;

    CardColor? leadColor = gameState.leadColor;
    if (leadColor != null && leadColor != CardColor.NONE) {
      bool hasLeadColor = player.hand.any((c) => c.color == leadColor && c.type == CardType.NUMBER);
      if (hasLeadColor) {
        return card.color == leadColor;
      }
    }
    return true;
  }
}
