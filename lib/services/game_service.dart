import 'dart:math';
import '../models/card.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/player.dart';

class GameService {
  final GameState _gameState = GameState();
  final Random _random = Random();

  GameState get gameState => _gameState;

  // Initialize Game
  void initGame(List<Player> players) {
    _gameState.players = players;
    _gameState.round = 1;
    _gameState.dealerIndex = 0;
    _gameState.currentPlayerIndex = 0; // Left of dealer starts
    // In Wizard, player to the left of dealer starts bidding/play
    _gameState.currentPlayerIndex = (_gameState.dealerIndex + 1) % _gameState.players.length;
  }

  // Generate 60-card Deck
  List<Card> _generateDeck() {
    List<Card> deck = [];
    
    // 1. Number Cards (1-13 in 4 colors)
    for (var color in [CardColor.BLOOD, CardColor.SPIRIT, CardColor.NATURE, CardColor.LIGHT]) {
      for (int i = 1; i <= 13; i++) {
        deck.add(Card(
          type: CardType.NUMBER,
          color: color,
          value: i,
          id: "${color.name}_$i",
          imageAssetPath: "assets/cards/${color.name.toLowerCase()}_$i.png",
        ));
      }
    }

    // 2. Arcanums (4)
    for (int i = 0; i < 4; i++) {
      deck.add(Card(
        type: CardType.ARCANUM,
        color: CardColor.NONE,
        value: 14, // High value for sorting
        id: "ARCANUM_$i",
        imageAssetPath: "assets/cards/arcanum.png",
      ));
    }

    // 3. Shadows (4)
    for (int i = 0; i < 4; i++) {
      deck.add(Card(
        type: CardType.SHADOW,
        color: CardColor.NONE,
        value: 0, // Low value
        id: "SHADOW_$i",
        imageAssetPath: "assets/cards/shadow.png",
      ));
    }

    return deck;
  }

  void startRound() {
    // 1. Reset Round State
    for (var p in _gameState.players) {
      p.resetRound();
    }
    _gameState.currentTrick = [];
    _gameState.deck = _generateDeck();
    _gameState.deck.shuffle(_random);

    // 2. Deal Cards
    int cardsToDeal = _gameState.round;
    int totalPlayers = _gameState.players.length;
    
    // QA-01: Check if we have enough cards (60 max)
    if (cardsToDeal * totalPlayers > 60) {
      throw Exception("Insufficient cards for round ${_gameState.round} with $totalPlayers players.");
    }
    
    for (int i = 0; i < cardsToDeal; i++) {
      for (var player in _gameState.players) {
        if (_gameState.deck.isNotEmpty) {
          player.hand.add(_gameState.deck.removeLast());
        }
      }
    }
    
    // Sort hands for better UX
    for (var player in _gameState.players) {
      player.hand.sort((a, b) {
        if (a.type != b.type) return a.type.index.compareTo(b.type.index);
        if (a.color != b.color) return a.color.index.compareTo(b.color.index);
        return a.value.compareTo(b.value);
      });
    }

    // 3. Determine Trump
    if (_gameState.deck.isNotEmpty) {
      Card trumpCard = _gameState.deck.removeLast();
      _gameState.trumpCard = trumpCard;
      
      if (trumpCard.type == CardType.ARCANUM) {
        // Dealer chooses trump color. 
        // For now, if dealer is bot, pick random or logic. If human, wait for input.
        // We'll set to NONE momentarily and let ViewModel handle the interaction.
        _gameState.trumpColor = null; // Needs input
      } else if (trumpCard.type == CardType.SHADOW) {
        _gameState.trumpColor = CardColor.NONE;
      } else {
        _gameState.trumpColor = trumpCard.color;
      }
    } else {
      // Last round, no cards left -> No trump
      _gameState.trumpCard = null;
      _gameState.trumpColor = CardColor.NONE;
    }

    // Set starting player (left of dealer)
    _gameState.currentPlayerIndex = (_gameState.dealerIndex + 1) % _gameState.players.length;
  }

  // Check if a move is valid
  bool isValidMove(Player player, Card card) {
    // QA-02: If trump is needed (ARCANUM turned up) but not yet chosen, move is invalid
    if (_gameState.trumpCard?.type == CardType.ARCANUM && _gameState.trumpColor == null) {
      return false;
    }

    if (_gameState.currentTrick.isEmpty) return true; // Lead any card

    CardColor? leadColor = _gameState.leadColor;
    
    // Arcanum and Shadow always valid
    if (card.type == CardType.ARCANUM || card.type == CardType.SHADOW) return true;

    // If lead color exists (not Jester led or first card was Jester)
    if (leadColor != null && leadColor != CardColor.NONE) {
      // Must follow suit if possible
      bool hasLeadColor = player.hand.any((c) => c.color == leadColor && c.type == CardType.NUMBER);
      if (hasLeadColor) {
        if (card.color == leadColor) return true;
        return false; // Must play lead color
      }
    }

    // If don't have lead color, can play anything
    return true;
  }

  void playCard(Player player, Card card) {
    if (!isValidMove(player, card)) {
      throw StateError("Invalid move: ${card.id} cannot be played now (check trump color selection).");
    }
    player.hand.remove(card);
    _gameState.currentTrick.add(PlayedCard(card: card, playerId: player.id));
    
    // Move to next player
    _gameState.currentPlayerIndex = (_gameState.currentPlayerIndex + 1) % _gameState.players.length;
  }

  Player evaluateTrickWinner() {
    if (_gameState.currentTrick.isEmpty) throw Exception("Empty trick");

    PlayedCard winningCard = _gameState.currentTrick[0];
    CardColor? leadColor = _gameState.leadColor; // Determine lead color from the trick itself

    for (int i = 1; i < _gameState.currentTrick.length; i++) {
      PlayedCard challenger = _gameState.currentTrick[i];
      if (challenger.card.beats(winningCard.card, _gameState.trumpColor, leadColor)) {
        winningCard = challenger;
      }
    }

    return _gameState.players.firstWhere((p) => p.id == winningCard.playerId);
  }

  void finishTrick(Player winner) {
    winner.wonTricks++;
    _gameState.currentTrick.clear();
    // Winner starts next trick
    _gameState.currentPlayerIndex = _gameState.players.indexOf(winner);
  }

  void finishRound() {
    for (var player in _gameState.players) {
      int diff = (player.predictedTricks - player.wonTricks).abs();
      int roundScore = 0;
      if (diff == 0) {
        roundScore = 20 + (10 * player.wonTricks);
      } else {
        roundScore = -(10 * diff);
      }
      player.score += roundScore;
      player.scoreHistory.add(player.score); // Track cumulative score
    }
    
    // Prepare next round
    _gameState.round++;
    _gameState.dealerIndex = (_gameState.dealerIndex + 1) % _gameState.players.length;
  }
}
