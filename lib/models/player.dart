import 'card.dart';
import 'game_state.dart';
import 'enums.dart';

abstract class Player {
  String id;
  String name;
  List<Card> hand = [];
  int predictedTricks = 0;
  int wonTricks = 0;
  int score = 0;
  List<int> scoreHistory = [];

  Player({required this.id, required this.name});

  Future<int> makePrediction(GameState gameState);
  Future<Card> playCard(GameState gameState);

  void resetRound() {
    hand.clear();
    predictedTricks = 0;
    wonTricks = 0;
  }
}

class HumanPlayer extends Player {
  HumanPlayer({required super.id, required super.name});

  @override
  Future<int> makePrediction(GameState gameState) {
    throw UnimplementedError("Human prediction is handled via UI interaction");
  }

  @override
  Future<Card> playCard(GameState gameState) {
    throw UnimplementedError("Human play is handled via UI interaction");
  }
}

class BotPlayer extends Player {
  final double riskFactor; // -0.5 (cautious) to +0.5 (risky)
  final int skillLevel;    // 1 (basic) to 3 (expert)

  BotPlayer({
    required super.id, 
    required super.name,
    this.riskFactor = 0.0,
    this.skillLevel = 2,
  });

  @override
  Future<int> makePrediction(GameState gameState) async {
    // Simple heuristic for now
    int prediction = 0;
    for (var card in hand) {
      if (card.type == CardType.ARCANUM) {
        prediction++;
      } else if (card.type == CardType.NUMBER && (card.value == 13 || card.value == 12)) {
        // Kings and Aces
        prediction++;
      }
    }
    return prediction;
  }

  @override
  Future<Card> playCard(GameState gameState) async {
    return hand.first;
  }
}
