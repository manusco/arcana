import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/high_score_service.dart';
import '../services/localization_service.dart';

class HighScoreWidget extends StatelessWidget {
  final List<HighScoreEntry> scores;
  
  const HighScoreWidget({
    super.key,
    required this.scores,
  });
  
  @override
  Widget build(BuildContext context) {
    final topScores = scores.take(5).toList();
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    context.watch<LocalizationService>().translate('high_scores'),
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.amber),
                onPressed: () => Navigator.pop(context),
                tooltip: context.watch<LocalizationService>().translate('close_tooltip'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Content - either scores or empty state
          if (topScores.isEmpty)
            // Empty state
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.watch<LocalizationService>().translate('no_high_scores_yet'),
                    style: GoogleFonts.roboto(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            // Scores list
            ...topScores.asMap().entries.map((entry) {
              int rank = entry.key + 1;
              var score = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
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
                    // Rank
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: rank == 1 
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: GoogleFonts.robotoMono(
                            color: rank == 1 ? Colors.black : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Username
                    Expanded(
                      child: Text(
                        score.username,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: rank == 1 ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Score
                    Text(
                      '${score.score}',
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
