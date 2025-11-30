import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../models/enums.dart';
import '../services/game_service.dart';
import '../services/ai_service.dart';
import '../services/high_score_service.dart';

class GameViewModel extends ChangeNotifier {
  final GameService _gameService = GameService();
  final AiService _aiService = AiService();

  GamePhase _phase = GamePhase.SETUP;
  GamePhase get phase => _phase;

  GameState get gameState => _gameService.gameState;

  // UI State helpers
  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  String? _username;
  String? get username => _username;

  void startGame(int playerCount, [String? username]) {
    print("startGame called with $playerCount players");
    try {
      _username = username;
      
      // Create players
      List<Player> players = [
        HumanPlayer(id: "p1", name: username ?? "You"),
      ];

      // Bot Personalities
      final botConfigs = [
        {'name': 'Mio', 'risk': 0.0, 'skill': 3},      // The Pro
        {'name': 'Nea', 'risk': 0.2, 'skill': 3},      // Intuitive
        {'name': 'Nero', 'risk': 0.5, 'skill': 2},     // Aggressor
        {'name': 'Aura', 'risk': -0.3, 'skill': 2},    // Cautious
        {'name': 'Varius', 'risk': 0.0, 'skill': 1},   // Chaotic
        {'name': 'Sol', 'risk': 0.1, 'skill': 2},      // Optimist
      ];
      
      for (int i = 0; i < playerCount - 1; i++) {
        var config = botConfigs[i % botConfigs.length];
        players.add(BotPlayer(
          id: "b${i+1}", 
          name: config['name'] as String,
          riskFactor: config['risk'] as double,
          skillLevel: config['skill'] as int,
        ));
      }
      
      print("Initializing game service...");
      _gameService.initGame(players);
      print("Game initialized. Starting round...");
      _startRound();
    } catch (e, stack) {
      print("Error in startGame: $e");
      print(stack);
      _statusMessage = "Error starting game: $e";
      notifyListeners();
    }
  }

  void restartGame(int playerCount, [String? username]) {
    startGame(playerCount, username);
  }

  void _startRound() {
    print("_startRound called");
    try {
      _phase = GamePhase.SETUP;
      _gameService.startRound();
      print("Round started in service. Notifying listeners...");
      notifyListeners();

      // Check if Dealer needs to choose Trump (Wizard turned up)
      if (_gameService.gameState.trumpCard?.type == CardType.ARCANUM) {
        Player dealer = _gameService.gameState.players[_gameService.gameState.dealerIndex];
        if (dealer is BotPlayer) {
          // Bot chooses trump (random for now, or based on hand)
          _gameService.gameState.trumpColor = CardColor.values[DateTime.now().millisecond % 4]; // Random valid color
          _statusMessage = "${dealer.name} chose ${_gameService.gameState.trumpColor?.name} as Trump";
          _advanceToBidding();
        } else {
          // Human dealer - UI should show dialog
          _statusMessage = "Choose a Trump Color!";
          notifyListeners();
          // Wait for user input via setTrumpColor
        }
      } else {
        _advanceToBidding();
      }
    } catch (e, stack) {
      print("Error in _startRound: $e");
      print(stack);
      _statusMessage = "Error starting round: $e";
      notifyListeners();
    }
  }

  void setTrumpColor(CardColor color) {
    if (_gameService.gameState.trumpCard?.type == CardType.ARCANUM) {
      _gameService.gameState.trumpColor = color;
      _advanceToBidding();
    }
  }

  void _advanceToBidding() {
    _phase = GamePhase.BIDDING;
    _statusMessage = "Bidding Phase";
    notifyListeners();
    _processTurn();
  }

  Future<void> _processTurn() async {
    if (_phase == GamePhase.BIDDING) {
      Player current = _gameService.gameState.currentPlayer;
      if (current is BotPlayer) {
        await Future.delayed(const Duration(milliseconds: 1000)); // UX delay
        int bid = _aiService.calculateBid(current, _gameService.gameState);
        
        // Apply dealer rule: last bidder cannot make total equal to round
        int dealerIndex = _gameService.gameState.dealerIndex;
        int currentIndex = _gameService.gameState.currentPlayerIndex;
        int starterIndex = (dealerIndex + 1) % _gameService.gameState.players.length;
        bool isLastBidder = ((currentIndex + 1) % _gameService.gameState.players.length) == starterIndex;
        
        if (isLastBidder) {
          int totalBids = 0;
          for (var player in _gameService.gameState.players) {
            if (player.id != current.id) {
              totalBids += player.predictedTricks;
            }
          }
          
          // If calculated bid would make total equal to round, adjust it
          if (totalBids + bid == _gameService.gameState.round) {
            // Try bid + 1 first, then bid - 1
            if (bid < _gameService.gameState.round) {
              bid = bid + 1;
            } else if (bid > 0) {
              bid = bid - 1;
            } else {
              bid = 1; // Must bid at least 1 if 0 is forbidden
            }
          }
        }
        
        current.predictedTricks = bid;
        _statusMessage = "${current.name} bids $bid";
        notifyListeners();
        _nextPlayerBidding();
      } else {
        // Human turn - wait for UI
        _statusMessage = "Your turn to bid!";
        notifyListeners();
      }
    } else if (_phase == GamePhase.PLAYING) {
      Player current = _gameService.gameState.currentPlayer;
      if (current is BotPlayer) {
        await Future.delayed(const Duration(milliseconds: 1500)); // UX delay
        Card card = _aiService.chooseCardToPlay(current, _gameService.gameState);
        _playCardInternal(current, card);
      } else {
        // Human turn
        _statusMessage = "Your turn to play!";
        notifyListeners();
      }
    }
  }

  void _nextPlayerBidding() {
    // Move to next player
    int currentIndex = _gameService.gameState.currentPlayerIndex;
    int starterIndex = (_gameService.gameState.dealerIndex + 1) % _gameService.gameState.players.length;
    
    int nextIndex = (currentIndex + 1) % _gameService.gameState.players.length;
    
    if (nextIndex == starterIndex) {
      // Everyone has bid
      _phase = GamePhase.PLAYING;
      _gameService.gameState.currentPlayerIndex = starterIndex; // Starter leads first trick
      _statusMessage = "Play Phase Started!";
      notifyListeners();
      _processTurn();
    } else {
      _gameService.gameState.currentPlayerIndex = nextIndex;
      notifyListeners();
      _processTurn();
    }
  }

  void submitBid(int bid) {
    if (_phase != GamePhase.BIDDING) return;
    Player current = _gameService.gameState.currentPlayer;
    if (current is HumanPlayer) {
      current.predictedTricks = bid;
      _nextPlayerBidding();
    }
  }

  void playCard(Card card) {
    if (_phase != GamePhase.PLAYING) return;
    Player current = _gameService.gameState.currentPlayer;
    if (current is HumanPlayer) {
      if (_gameService.isValidMove(current, card)) {
        _playCardInternal(current, card);
      } else {
        _statusMessage = "Invalid Move!";
        notifyListeners();
      }
    }
  }

  void _playCardInternal(Player player, Card card) async {
    _gameService.playCard(player, card);
    notifyListeners();

    if (_gameService.gameState.currentTrick.length == _gameService.gameState.players.length) {
      // Trick complete
      await Future.delayed(const Duration(milliseconds: 2000)); // Show trick result
      Player winner = _gameService.evaluateTrickWinner();
      _statusMessage = "${winner.name} won the trick!";
      _gameService.finishTrick(winner);
      notifyListeners();

      if (player.hand.isEmpty) {
        // Round complete
        _gameService.finishRound();
        _phase = GamePhase.ROUND_OVER;
        _statusMessage = "Round Over!";
        notifyListeners();
        
        // Wait then start next round
        await Future.delayed(const Duration(seconds: 3));
        if (_gameService.gameState.round > 60 ~/ _gameService.gameState.players.length) {
           _phase = GamePhase.GAME_OVER;
           _statusMessage = "Game Over!";
           
           // Save high score if username provided
           if (_username != null && _username!.isNotEmpty) {
             final humanPlayer = _gameService.gameState.players[0];
             await HighScoreService().saveHighScore(_username!, humanPlayer.score);
           }
           
           notifyListeners();
        } else {
           _startRound();
        }
      } else {
        // Next trick led by winner
        _processTurn();
      }
    } else {
      // Next player in trick
      _processTurn();
    }
  }
}
