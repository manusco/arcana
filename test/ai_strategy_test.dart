import 'package:flutter_test/flutter_test.dart';
import 'package:magic_cards/models/card.dart';
import 'package:magic_cards/models/enums.dart';
import 'package:magic_cards/models/player.dart';
import 'package:magic_cards/models/game_state.dart';
import 'package:magic_cards/services/ai_service.dart';

void main() {
  late AiService aiService;
  late GameState gameState;

  setUp(() {
    aiService = AiService();
    gameState = GameState();
  });

  group('AI Bidding Strategy', () {
    test('Wizards should bid 1 each', () {
      final player = BotPlayer(id: '1', name: 'AI');
      player.hand.add(Card(type: CardType.ARCANUM, color: CardColor.NONE, id: 'w1', imageAssetPath: ''));
      player.hand.add(Card(type: CardType.ARCANUM, color: CardColor.NONE, id: 'w2', imageAssetPath: ''));
      
      final bid = aiService.calculateBid(player, gameState);
      expect(bid, 2);
    });

    test('Shadows should bid 0', () {
      final player = BotPlayer(id: '1', name: 'AI');
      player.hand.add(Card(type: CardType.SHADOW, color: CardColor.NONE, id: 's1', imageAssetPath: ''));
      player.hand.add(Card(type: CardType.SHADOW, color: CardColor.NONE, id: 's2', imageAssetPath: ''));
      
      final bid = aiService.calculateBid(player, gameState);
      expect(bid, 0);
    });

    test('High trumps should likely bid 1', () {
      final player = BotPlayer(id: '1', name: 'AI');
      gameState.trumpColor = CardColor.BLOOD;
      player.hand.add(Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 13, id: 't13', imageAssetPath: ''));
      
      final bid = aiService.calculateBid(player, gameState);
      expect(bid, 1);
    });
  });

  group('AI Playing Strategy', () {
    test('Should try to win with highest non-wizard when leading', () {
      final player = BotPlayer(id: '1', name: 'AI');
      player.predictedTricks = 1;
      player.wonTricks = 0;
      
      final low = Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 2, id: 'low', imageAssetPath: '');
      final high = Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 12, id: 'high', imageAssetPath: '');
      
      player.hand.addAll([low, high]);
      
      final chosen = aiService.chooseCardToPlay(player, gameState);
      expect(chosen.id, 'high');
    });

    test('Should try to lose with lowest when leading and target met', () {
      final player = BotPlayer(id: '1', name: 'AI');
      player.predictedTricks = 1;
      player.wonTricks = 1;
      
      final low = Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 2, id: 'low', imageAssetPath: '');
      final high = Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 12, id: 'high', imageAssetPath: '');
      
      player.hand.addAll([low, high]);
      
      final chosen = aiService.chooseCardToPlay(player, gameState);
      expect(chosen.id, 'low');
    });
  });
}
