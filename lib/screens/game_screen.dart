import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodels/game_viewmodel.dart';
import '../models/enums.dart';
import '../widgets/player_widget.dart';
import '../widgets/card_widget.dart';
import '../services/high_score_service.dart';
import '../widgets/high_score_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Offset _biddingOverlayPos = const Offset(50, 150); // Default position

  @override
  void initState() {
    super.initState();
    // Delay to show dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameSetupDialog();
    });
  }

  void _showGameSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GameSetupDialog(
        onStart: (count, username) {
          context.read<GameViewModel>().startGame(count, username);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    final state = vm.gameState;

    if (state.players.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _showGameSetupDialog,
                child: const Text("Start New Game"),
              ),
              if (vm.statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    vm.statusMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Felt texture using CSS pattern
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B5E20),
              const Color(0xFF2E7D32),
              const Color(0xFF1B5E20),
            ],
          ),
        ),
        child: Container(
          // Wood border
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3E2723), width: 8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            // Vignette effect
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
                radius: 1.2,
                center: Alignment.center,
              ),
            ),
            child: Stack(
              children: [
                // Felt texture overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.network(
                      "https://www.transparenttextures.com/patterns/asfalt-dark.png",
                      repeat: ImageRepeat.repeat,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                  ),
                ),

            // --- Players ---
            // Top Player (Partner/Opponent) - Index 2
            if (state.players.length > 2)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: PlayerWidget(
                    player: state.players[2],
                    isCurrentPlayer: state.currentPlayerIndex == 2,
                    isDealer: state.dealerIndex == 2,
                    isStartingPlayer: vm.phase == GamePhase.PLAYING && state.currentTrick.isEmpty && state.currentPlayerIndex == 2,
                  ),
                ),
              ),

            // Left Player - Index 1
            if (state.players.length > 1)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: PlayerWidget(
                    player: state.players[1],
                    isCurrentPlayer: state.currentPlayerIndex == 1,
                    isDealer: state.dealerIndex == 1,
                    isStartingPlayer: vm.phase == GamePhase.PLAYING && state.currentTrick.isEmpty && state.currentPlayerIndex == 1,
                  ),
                ),
              ),

            // Right Player - Index 3
            if (state.players.length > 3)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PlayerWidget(
                    player: state.players[3],
                    isCurrentPlayer: state.currentPlayerIndex == 3,
                    isDealer: state.dealerIndex == 3,
                    isStartingPlayer: vm.phase == GamePhase.PLAYING && state.currentTrick.isEmpty && state.currentPlayerIndex == 3,
                  ),
                ),
              ),
              
            // Extra Players (if > 4)
            if (state.players.length > 4)
               Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 80),
                  child: PlayerWidget(
                    player: state.players[4],
                    isCurrentPlayer: state.currentPlayerIndex == 4,
                    isDealer: state.dealerIndex == 4,
                    isStartingPlayer: vm.phase == GamePhase.PLAYING && state.currentTrick.isEmpty && state.currentPlayerIndex == 4,
                  ),
                ),
              ),
            if (state.players.length > 5)
               Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, right: 80),
                  child: PlayerWidget(
                    player: state.players[5],
                    isCurrentPlayer: state.currentPlayerIndex == 5,
                    isDealer: state.dealerIndex == 5,
                    isStartingPlayer: vm.phase == GamePhase.PLAYING && state.currentTrick.isEmpty && state.currentPlayerIndex == 5,
                  ),
                ),
              ),


            // --- Bottom Area (My Player & Hand) ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // My Info
                  PlayerWidget(
                    player: state.players[0],
                    isCurrentPlayer: state.currentPlayerIndex == 0,
                    isDealer: state.dealerIndex == 0,
                    isStartingPlayer: vm.phase == GamePhase.PLAYING && state.currentTrick.isEmpty && state.currentPlayerIndex == 0,
                  ),
                  const SizedBox(height: 8),
                  // My Hand
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.players[0].hand.length,
                      itemBuilder: (context, index) {
                        final card = state.players[0].hand[index];
                        return CardWidget(
                          card: card,
                          onTap: () {
                             if (vm.phase == GamePhase.PLAYING && state.currentPlayerIndex == 0) {
                               vm.playCard(card);
                             }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // --- Center Area (Trick & Trump) --- (Moved after bottom to render on top)
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  children: [
                    // Current Trick
                    ...state.currentTrick.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var playedCard = entry.value;
                      int pIndex = state.players.indexWhere((p) => p.id == playedCard.playerId);
                      
                      Alignment align = Alignment.center;
                      double rot = 0;
                      
                      if (pIndex == 0) { align = Alignment.bottomCenter; rot = 0; }
                      else if (pIndex == 1) { align = Alignment.centerLeft; rot = 1.57; }
                      else if (pIndex == 2) { align = Alignment.topCenter; rot = 3.14; }
                      else if (pIndex == 3) { align = Alignment.centerRight; rot = -1.57; }
                      else if (pIndex == 4) { align = Alignment.topLeft; rot = 2.3; }
                      else if (pIndex == 5) { align = Alignment.topRight; rot = -2.3; }

                      return Align(
                        alignment: align,
                        child: Transform.translate(
                          offset: pIndex == 0 ? const Offset(0, -20) : 
                                  pIndex == 1 ? const Offset(20, 0) :
                                  pIndex == 2 ? const Offset(0, 20) :
                                  pIndex == 3 ? const Offset(-20, 0) :
                                  Offset.zero,
                          child: Transform.rotate(
                            angle: rot + (idx * 0.1), // Slight randomness
                            child: CardWidget(card: playedCard.card, width: 70, height: 105),
                          ),
                        ),
                      ).animate().fadeIn().scale();
                    }).toList(),
                  ],
                ),
              ),
            ),

            // --- Status Message ---
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                ),
                child: Text(
                  vm.statusMessage ?? "",
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [
                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
                  ]),
                ),
              ).animate().fadeIn(),
            ),

            // --- Trump Card (Moved to Top Left) ---
            if (state.trumpCard != null)
              Positioned(
                top: 10,
                left: 10,
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("TRUMP", style: GoogleFonts.cinzel(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        CardWidget(
                          card: state.trumpCard!,
                          width: 40,
                          height: 60,
                        ),
                        if (vm.phase == GamePhase.BIDDING || vm.phase == GamePhase.PLAYING)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              state.trumpColor?.name ?? "NONE",
                              style: GoogleFonts.robotoMono(
                                color: _getColor(state.trumpColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- Bidding Overlay (Draggable & Smaller) ---
            if (vm.phase == GamePhase.BIDDING && state.currentPlayerIndex == 0)
              Positioned(
                left: _biddingOverlayPos.dx,
                top: _biddingOverlayPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _biddingOverlayPos += details.delta;
                    });
                  },
                  child: Container(
                    width: 300, // Constrain width
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Your Bid",
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: List.generate(state.round + 1, (index) {
                            // Calculate if this is the last bidder (dealer)
                            int dealerIndex = state.dealerIndex;
                            int currentIndex = state.currentPlayerIndex;
                            int starterIndex = (dealerIndex + 1) % state.players.length;
                            bool isLastBidder = ((currentIndex + 1) % state.players.length) == starterIndex;
                            
                            // Calculate total bids so far
                            int totalBids = 0;
                            for (var player in state.players) {
                              if (player.predictedTricks > 0 || player.id != state.currentPlayer.id) {
                                totalBids += player.predictedTricks;
                              }
                            }
                            
                            // Check if this bid would make total equal to round (forbidden for last bidder)
                            bool isForbidden = isLastBidder && (totalBids + index) == state.round;
                            
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isForbidden 
                                      ? Colors.grey.withOpacity(0.3)
                                      : const Color(0xFFFFD700),
                                  foregroundColor: isForbidden ? Colors.grey : Colors.black,
                                  padding: EdgeInsets.zero,
                                  shape: const CircleBorder(),
                                  elevation: isForbidden ? 0 : 4,
                                ),
                                onPressed: isForbidden ? null : () => vm.submitBid(index),
                                child: Text(
                                  "$index",
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
              
            // --- Trump Selection Overlay ---
            if (vm.phase == GamePhase.SETUP && state.trumpCard?.type == CardType.ARCANUM && state.dealerIndex == 0)
               Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Choose Trump Color", style: GoogleFonts.cinzel(color: Colors.white, fontSize: 24)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _colorBtn(CardColor.BLOOD, vm),
                          _colorBtn(CardColor.SPIRIT, vm),
                          _colorBtn(CardColor.NATURE, vm),
                          _colorBtn(CardColor.LIGHT, vm),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(),

            // --- Scoreboard Button ---
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                    onPressed: _showGameSetupDialog,
                    tooltip: "Restart Game",
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 32),
                    onPressed: () => _showScoreboard(context, state.players),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScoreboard(BuildContext context, List<dynamic> players) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Scoreboard", style: GoogleFonts.cinzel(color: Colors.white)),
        content: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.white24),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header
              TableRow(
                children: [
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Rnd", style: TextStyle(color: Colors.amber))),
                  ...players.map((p) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(p.name, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  )),
                ],
              ),
              // Rows (we need to transpose the history lists essentially)
              // Assuming all players have same history length
              if (players.isNotEmpty)
                ...List.generate(players[0].scoreHistory.length, (roundIdx) {
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text("${roundIdx + 1}", style: const TextStyle(color: Colors.white70))),
                      ...players.map((p) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("${p.scoreHistory[roundIdx]}", style: const TextStyle(color: Colors.white)),
                      )),
                    ],
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _colorBtn(CardColor color, GameViewModel vm) {
    return GestureDetector(
      onTap: () => vm.setTrumpColor(color),
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getColor(color),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Color _getColor(CardColor? color) {
    switch (color) {
      case CardColor.BLOOD: return Colors.red;
      case CardColor.SPIRIT: return Colors.blue;
      case CardColor.NATURE: return Colors.green;
      case CardColor.LIGHT: return Colors.amber;
      default: return Colors.white;
    }
  }
}

class _GameSetupDialog extends StatefulWidget {
  final Function(int, String?) onStart;
  const _GameSetupDialog({required this.onStart});

  @override
  State<_GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<_GameSetupDialog> {
  int _playerCount = 4;
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text("New Game", style: GoogleFonts.cinzel(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Your Name (optional)',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Enter name for high score',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber.withOpacity(0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => _username = value.trim()),
          ),
          const SizedBox(height: 24),
          const Text("Select Number of Players:", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.amber),
                onPressed: () {
                  if (_playerCount > 2) setState(() => _playerCount--);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("$_playerCount", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.amber),
                onPressed: () {
                  if (_playerCount < 6) setState(() => _playerCount++);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
          onPressed: () => widget.onStart(_playerCount, _username.isEmpty ? null : _username),
          child: const Text("Start"),
        ),
      ],
    );
  }

  String _getPlacementText(List<dynamic> players) {
    // Sort players by score
    var sortedPlayers = List.from(players);
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    
    // Find player's position
    int position = sortedPlayers.indexWhere((p) => p.id == "p1") + 1;
    
    if (position == 2) return "2ND PLACE";
    if (position == 3) return "3RD PLACE";
    return "${position}TH PLACE";
  }
}
