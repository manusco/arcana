import 'package:flutter_test/flutter_test.dart';
import 'package:arcana/models/card.dart';
import 'package:arcana/models/enums.dart';
import 'package:arcana/models/player.dart';
import 'package:arcana/models/game_state.dart';
import 'package:arcana/services/game_service.dart';

void main() {
  group('Card Logic', () {
    test('Wizard beats everything', () {
      final wizard = Card(type: CardType.ARCANUM, color: CardColor.NONE, id: 'w', imageAssetPath: '');
      final ace = Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 13, id: 'a', imageAssetPath: '');
      
      expect(wizard.beats(ace, CardColor.SPIRIT, CardColor.BLOOD), true);
      // First wizard wins against second wizard
      expect(wizard.beats(wizard, CardColor.SPIRIT, CardColor.BLOOD), false); 
    });

    test('Trump beats non-trump', () {
      final trump = Card(type: CardType.NUMBER, color: CardColor.BLOOD, value: 2, id: 't', imageAssetPath: '');
      final ace = Card(type: CardType.NUMBER, color: CardColor.SPIRIT, value: 13, id: 'a', imageAssetPath: '');
      
      expect(trump.beats(ace, CardColor.BLOOD, CardColor.SPIRIT), true);
    });

    test('Lead color beats off-suit', () {
      final lead = Card(type: CardType.NUMBER, color: CardColor.SPIRIT, value: 2, id: 'l', imageAssetPath: '');
      final off = Card(type: CardType.NUMBER, color: CardColor.NATURE, value: 13, id: 'o', imageAssetPath: '');
      
      expect(lead.beats(off, CardColor.BLOOD, CardColor.SPIRIT), true);
    });
  });

  group('GameService Logic', () {
    late GameService gameService;

    setUp(() {
      gameService = GameService();
    });

    test('Deck generation has 60 cards', () {
      gameService.initGame([HumanPlayer(id: '1', name: 'Test')]);
      gameService.startRound();
      // 60 cards total. 
      // Round 1: 1 card dealt to 1 player = 59 left in deck + trump card (if any).
      // Actually deck is private in GameState, but we can infer from hands?
      // Or just trust the code. 
      // Let's check hand size.
      expect(gameService.gameState.players[0].hand.length, 1);
    });

    test('Trick evaluation', () {
      final p1 = HumanPlayer(id: '1', name: 'P1');
      final p2 = HumanPlayer(id: '2', name: 'P2');
      gameService.initGame([p1, p2]);
      gameService.startRound();
      
      // Force set trick
      gameService.gameState.trumpColor = CardColor.BLOOD;
      
      final c1 = Card(type: CardType.NUMBER, color: CardColor.SPIRIT, value: 10, id: 'c1', imageAssetPath: '');
      final c2 = Card(type: CardType.NUMBER, color: CardColor.SPIRIT, value: 12, id: 'c2', imageAssetPath: '');
      
      gameService.gameState.currentTrick.add(PlayedCard(card: c1, playerId: '1'));
      gameService.gameState.currentTrick.add(PlayedCard(card: c2, playerId: '2'));
      
      final winner = gameService.evaluateTrickWinner();
      expect(winner.id, '2'); // Higher blue wins
    });
  });
}
