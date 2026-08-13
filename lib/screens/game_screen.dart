import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      // Set the localization service in the view model
      final vm = context.read<GameViewModel>();
      final loc = context.read<LocalizationService>();
      vm.setLocalizationService(loc);

      _showGameSetupDialog();
      _maybeShowRulesOnFirstRun();
    });
  }

  // Auto-open the rules dialog the first time the game is ever launched, so a
  // new player sees how to play. A persisted flag makes this happen only once.
  Future<void> _maybeShowRulesOnFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool('arcana_seen_rules') ?? false;
    if (seen) return;
    await prefs.setBool('arcana_seen_rules', true);
    if (!mounted) return;
    _showRulesDialog();
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
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
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
                      Colors.amber.withValues(alpha: 0.2),
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
                            color: Colors.amber.withValues(alpha: 0.8),
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
              color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.amber.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: GoogleFonts.roboto(
                      color: Colors.white.withValues(alpha: 0.85),
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
              color: Colors.amber.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.roboto(
              color: Colors.white.withValues(alpha: 0.85),
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
                color: Colors.white.withValues(alpha: 0.85),
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
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                ],
                radius: 1.2,
                center: Alignment.center,
              ),
            ),
            child: Stack(
              children: [
                // Felt texture overlay (bundled locally, no runtime network request)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      "assets/images/felt_texture.png",
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
                        // During the human's play turn, dim and disable cards
                        // that are not legal to play (follow-suit rule) instead
                        // of only rejecting an illegal tap.
                        final bool isMyPlayTurn =
                            vm.phase == GamePhase.PLAYING && state.currentPlayerIndex == 0;
                        final bool legal = vm.canHumanPlay(card);
                        final bool dim = isMyPlayTurn && !legal;
                        return Opacity(
                          opacity: dim ? 0.35 : 1.0,
                          child: CardWidget(
                            card: card,
                            onTap: (isMyPlayTurn && legal) ? () => vm.playCard(card) : null,
                          ),
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
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 2),
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
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(loc.translate('trump_label').toUpperCase(), style: GoogleFonts.cinzel(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
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
                                      ? Colors.grey.withValues(alpha: 0.3)
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
                    tooltip: loc.translate('scoreboard_title'),
                  ),
                ],
              ),
            ),
            
            // --- Logo Watermark ---
            Positioned(
              bottom: 80,
              right: 20,
              child: Opacity(
                opacity: 0.3,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcOut,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcOut,
                      ),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Round Result Panel (per-round feedback) ---
            if (vm.phase == GamePhase.ROUND_OVER)
              Positioned.fill(
                child: _RoundResultPanel(players: state.players),
              ),

            // --- Game Over Overlay ---
            if (vm.phase == GamePhase.GAME_OVER)
              Positioned.fill(
                child: _GameOverOverlay(
                  players: state.players,
                  onPlayAgain: _showGameSetupDialog,
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.read<LocalizationService>().translate('close'))),
        ],
      ),
    );
  }

  Widget _colorBtn(CardColor color, GameViewModel vm) {
    final loc = context.read<LocalizationService>();
    final colorName = loc.translate('suit_${color.name.toLowerCase()}');
    final label = "${loc.translate('action_select')} $colorName";

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
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

              widget.onShowRules!();
            } : null,
            tooltip: context.watch<LocalizationService>().translate('how_to_play_title'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcOut,
            ),
            child: Container(
              color: Colors.white,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcOut,
                ),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Language Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _languageBtn(context, 'en', '🇬🇧'),
              const SizedBox(width: 20),
              _languageBtn(context, 'de', '🇩🇪'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.menu_book, color: Colors.amber, size: 20),
                label: Text(
                  context.watch<LocalizationService>().translate('how_to_play_title'),
                  style: const TextStyle(color: Colors.amber),
                ),
                onPressed: widget.onShowRules,
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                label: Text(
                  context.watch<LocalizationService>().translate('high_scores'),
                  style: const TextStyle(color: Colors.amber),
                ),
                onPressed: widget.onShowHighScores,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: context.watch<LocalizationService>().translate('enter_name'),
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: '',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            onChanged: (value) => setState(() => _username = value.trim()),
          ),
          const SizedBox(height: 24),
          Text("${context.watch<LocalizationService>().translate('number_of_players')}:", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle, color: _playerCount > 2 ? Colors.amber : Colors.grey),
                tooltip: context.watch<LocalizationService>().translate('action_decrease_players'),
                onPressed: _playerCount > 2 ? () => setState(() => _playerCount--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("$_playerCount", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: _playerCount < 6 ? Colors.amber : Colors.grey),
                tooltip: context.watch<LocalizationService>().translate('action_increase_players'),
                onPressed: _playerCount < 6 ? () => setState(() => _playerCount++) : null,
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
    final langName = loc.translate('lang_$code');
    final label = "${loc.translate('action_select')} $langName";

    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => loc.changeLocale(code),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.amber) : null,
          ),
          child: Text(flag, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

/// Per-round feedback panel shown during [GamePhase.ROUND_OVER]. For every
/// player it shows the predicted vs won tricks and the points delta for the
/// round that just finished. The delta is derived from the cumulative
/// scoreHistory (last entry minus the previous one), so it always matches the
/// engine's own scoring without duplicating the formula.
class _RoundResultPanel extends StatelessWidget {
  final List<dynamic> players;

  const _RoundResultPanel({required this.players});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a0033), Color(0xFF0d001a)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate('round_results'),
                  style: GoogleFonts.cinzel(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ...players.map((p) {
                  final int predicted = p.predictedTricks as int;
                  final int won = p.wonTricks as int;
                  final List history = p.scoreHistory as List;
                  final int delta = history.isEmpty
                      ? 0
                      : (history.last as int) -
                          (history.length >= 2 ? history[history.length - 2] as int : 0);
                  final String deltaStr = delta >= 0 ? '+$delta' : '$delta';
                  final String summary = loc
                      .translate('round_summary')
                      .replaceAll('{predicted}', '$predicted')
                      .replaceAll('{won}', '$won')
                      .replaceAll('{delta}', deltaStr);
                  final Color deltaColor = delta > 0
                      ? const Color(0xFF4CAF50)
                      : (delta < 0 ? Colors.redAccent : Colors.white70);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name as String,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                summary,
                                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          deltaStr,
                          style: GoogleFonts.robotoMono(
                            color: deltaColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// End-of-game overlay shown during [GamePhase.GAME_OVER]. Shows the final
/// standings (ranked by score), the human player's placement, the persisted
/// high-score board, and a prominent "Play Again" that resets to a new game.
class _GameOverOverlay extends StatefulWidget {
  final List<dynamic> players;
  final VoidCallback onPlayAgain;

  const _GameOverOverlay({required this.players, required this.onPlayAgain});

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay> {
  List<HighScoreEntry>? _scores;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = await HighScoreService().getHighScores();
    if (!mounted) return;
    setState(() => _scores = scores);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    // Rank players by score, highest first.
    final ranked = List<dynamic>.from(widget.players);
    ranked.sort((a, b) => (b.score as int).compareTo(a.score as int));

    // The human is player id "p1".
    final int humanRank = ranked.indexWhere((p) => p.id == 'p1') + 1;
    final dynamic winner = ranked.isNotEmpty ? ranked.first : null;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a0033), Color(0xFF0d001a)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.amber.withValues(alpha: 0.25), blurRadius: 24, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 48),
                const SizedBox(height: 12),
                Text(
                  loc.translate('game_over_title'),
                  style: GoogleFonts.cinzel(
                    color: Colors.amber,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (winner != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    loc.translate('winner_announcement').replaceAll('{player}', winner.name as String),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (humanRank > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    loc
                        .translate('your_placement')
                        .replaceAll('{place}', '$humanRank')
                        .replaceAll('{total}', '${ranked.length}'),
                    style: GoogleFonts.roboto(
                      color: const Color(0xFFFFD700),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                // Final standings
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.translate('final_standings'),
                    style: GoogleFonts.cinzel(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...ranked.asMap().entries.map((entry) {
                  final int rank = entry.key + 1;
                  final dynamic p = entry.value;
                  final bool isHuman = p.id == 'p1';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isHuman
                          ? Colors.amber.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rank == 1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '$rank',
                            style: GoogleFonts.robotoMono(
                              color: rank == 1 ? const Color(0xFFFFD700) : Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.name as String,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: isHuman ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${p.score}',
                          style: GoogleFonts.robotoMono(
                            color: const Color(0xFFFFD700),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // High-score board (inline)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        loc.translate('high_scores'),
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (_scores == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
                else if (_scores!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      loc.translate('no_high_scores_yet'),
                      style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._scores!.take(5).toList().asMap().entries.map((e) {
                    final int rank = e.key + 1;
                    final HighScoreEntry sc = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: Text(
                              '$rank',
                              style: GoogleFonts.robotoMono(
                                color: rank == 1 ? const Color(0xFFFFD700) : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sc.username,
                              style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${sc.score}',
                            style: GoogleFonts.robotoMono(
                              color: const Color(0xFFFFD700),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                // Play Again
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      loc.translate('play_again'),
                      style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: widget.onPlayAgain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
