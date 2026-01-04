import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodels/game_viewmodel.dart';
import '../models/enums.dart';
import '../widgets/player_widget.dart';
import '../widgets/card_widget.dart';
import '../services/high_score_service.dart';
import '../widgets/high_score_widget.dart';
import '../services/localization_service.dart';

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
        onShowRules: _showRulesDialog,
        onShowHighScores: _showHighScoresDialog,
      ),
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a0033),
                const Color(0xFF0d001a),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.watch<LocalizationService>().translate('game_rules'),
                      style: GoogleFonts.cinzel(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.amber),
                      onPressed: () => Navigator.pop(context),
                      tooltip: context.watch<LocalizationService>().translate('close'),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRuleSection(
                        icon: Icons.stars,
                        title: context.watch<LocalizationService>().translate('welcome_title'),
                        content: context.watch<LocalizationService>().translate('welcome_text'),
                      ),
                      const SizedBox(height: 20),
                      _buildRuleSection(
                        icon: Icons.flag,
                        title: context.watch<LocalizationService>().translate('goal_title'),
                        content: context.watch<LocalizationService>().translate('goal_text'),
                      ),
                      const SizedBox(height: 20),
                      _buildRuleSection(
                        icon: Icons.style,
                        title: context.watch<LocalizationService>().translate('cards_title'),
                        content: "",
                        children: [
                          _buildCardInfo(context.watch<LocalizationService>().translate('suits_title'), context.watch<LocalizationService>().translate('suits_text')),
                          _buildCardInfo(context.watch<LocalizationService>().translate('arcanum_title'), context.watch<LocalizationService>().translate('arcanum_text')),
                          _buildCardInfo(context.watch<LocalizationService>().translate('shadow_title'), context.watch<LocalizationService>().translate('shadow_text')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildRuleSection(
                        icon: Icons.play_circle,
                        title: context.watch<LocalizationService>().translate('how_to_play_title'),
                        content: "",
                        children: [
                          _buildStep(context.watch<LocalizationService>().translate('step_deal_title'), context.watch<LocalizationService>().translate('step_deal_text')),
                          _buildStep(context.watch<LocalizationService>().translate('step_trump_title'), context.watch<LocalizationService>().translate('step_trump_text')),
                          _buildStep(context.watch<LocalizationService>().translate('step_prophecy_title'), context.watch<LocalizationService>().translate('step_prophecy_text')),
                          _buildStep(context.watch<LocalizationService>().translate('step_action_title'), context.watch<LocalizationService>().translate('step_action_text')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildRuleSection(
                        icon: Icons.emoji_events,
                        title: context.watch<LocalizationService>().translate('scoring_title'),
                        content: "",
                        children: [
                          _buildScoreInfo(context.watch<LocalizationService>().translate('score_correct_title'), context.watch<LocalizationService>().translate('score_correct_text')),
                          _buildScoreInfo(context.watch<LocalizationService>().translate('score_failed_title'), context.watch<LocalizationService>().translate('score_failed_text')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          context.watch<LocalizationService>().translate('footer_text'),
                          style: GoogleFonts.cinzel(
                            color: Colors.amber.withOpacity(0.8),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHighScoresDialog() async {
    final service = HighScoreService();
    final scores = await service.getHighScores();
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HighScoreWidget(scores: scores),
      ),
    );
  }

  Widget _buildRuleSection({
    required IconData icon,
    required String title,
    required String content,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cinzel(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
        if (children != null) ...[
          const SizedBox(height: 8),
          ...children,
        ],
      ],
    );
  }

  Widget _buildCardInfo(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: Colors.amber, fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$name: ",
                    style: GoogleFonts.robotoMono(
                      color: Colors.amber.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: GoogleFonts.roboto(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: GoogleFonts.robotoMono(
              color: Colors.amber.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.robotoMono(
              color: label.startsWith("✓") ? Colors.green : Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    final loc = context.watch<LocalizationService>();
    final state = vm.gameState;

    if (state.players.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _showGameSetupDialog,
                    child: Text(loc.translate('start_new_game')),
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

          ],
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
                          loc.translate('your_bid'),
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
                      Text(loc.translate('choose_trump'), style: GoogleFonts.cinzel(color: Colors.white, fontSize: 24)),
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
                    tooltip: loc.translate('restart_tooltip'),
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
        title: Text(context.read<LocalizationService>().translate('scoreboard_title'), style: GoogleFonts.cinzel(color: Colors.white)),
        content: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(color: Colors.white24),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(context.read<LocalizationService>().translate('round_abbr'), style: const TextStyle(color: Colors.amber))),
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
  final VoidCallback? onShowRules;
  final VoidCallback? onShowHighScores;
  
  const _GameSetupDialog({
    required this.onStart,
    this.onShowRules,
    this.onShowHighScores,
  });

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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.watch<LocalizationService>().translate('start_new_game'), style: GoogleFonts.cinzel(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.amber),
            onPressed: widget.onShowRules != null ? () {
              print("Help icon clicked. Calling onShowRules.");
              widget.onShowRules!();
            } : null,
            tooltip: context.watch<LocalizationService>().translate('how_to_play_title'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _languageBtn(context, 'en', '🇺🇸'),
              const SizedBox(width: 20),
              _languageBtn(context, 'de', '🇩🇪'),
            ],
          ),
          const SizedBox(height: 10),
          // TextButton.icon(
          //   icon: const Icon(Icons.emoji_events, color: Colors.amber),
          //   label: Text(context.watch<LocalizationService>().translate('high_scores'), style: const TextStyle(color: Colors.amber)),
          //   onPressed: widget.onShowHighScores,
          // ),
          const SizedBox(height: 10),
          // Need to import services for autofill
          TextField(
            decoration: InputDecoration(
              labelText: context.watch<LocalizationService>().translate('enter_name'),
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: context.watch<LocalizationService>().translate('enter_name'),
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
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          Text("${context.watch<LocalizationService>().translate('number_of_players')}:", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.amber),
                onPressed: () {
                  if (_playerCount > 2) setState(() => _playerCount--);
                },
                tooltip: context.watch<LocalizationService>().translate('remove_player'),
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
                tooltip: context.watch<LocalizationService>().translate('add_player'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
          onPressed: () => widget.onStart(_playerCount, _username.isEmpty ? null : _username),
          child: Text(context.watch<LocalizationService>().translate('start_game')),
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

  Widget _languageBtn(BuildContext context, String code, String flag) {
    final loc = context.watch<LocalizationService>();
    final isSelected = loc.currentLocale.languageCode == code;
    return GestureDetector(
      onTap: () => loc.changeLocale(code),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.amber) : null,
        ),
        child: Text(flag, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
