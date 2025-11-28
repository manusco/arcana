import 'card.dart';
import 'player.dart';
import 'enums.dart';

class PlayedCard {
  final Card card;
  final String playerId;

  PlayedCard({required this.card, required this.playerId});
}

class GameState {
  int round = 1;
  List<Player> players = [];
  List<Card> deck = [];
  Card? trumpCard;
  CardColor? trumpColor;
  List<PlayedCard> currentTrick = [];
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  
  // Helper to get current player
  Player get currentPlayer => players[currentPlayerIndex];

  // Helper to get lead color of the current trick
  CardColor? get leadColor {
    if (currentTrick.isEmpty) return null;
    // Find the first non-Jester card to determine lead color
    // If all are Jesters, no lead color (effectively)
    for (var played in currentTrick) {
      if (played.card.type != CardType.SHADOW) {
        return played.card.color;
      }
    }
    return null; // Or maybe the first Jester determines it? Rules say "no suit" if Jester led.
  }
}
