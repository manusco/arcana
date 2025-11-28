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
    _username = username;
    
    // Create players
    List<Player> players = [
      HumanPlayer(id: "p1", name: username ?? "You"),
    ];

    List<String> botNames = ["Merlin", "Gandalf", "Dumbledore", "Morgana", "Saruman"];
    
    for (int i = 0; i < playerCount - 1; i++) {
      players.add(BotPlayer(id: "b${i+1}", name: botNames[i % botNames.length]));
    }
    
    _gameService.initGame(players);
    _startRound();
  }

  void restartGame(int playerCount, [String? username]) {
    startGame(playerCount, username);
  }

  void _startRound() {
    _phase = GamePhase.SETUP;
    _gameService.startRound();
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
