import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isDealer;
  final bool isStartingPlayer;

  const PlayerWidget({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isDealer = false,
    this.isStartingPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.none, // Allow badges to overflow
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentPlayer
            ? Border.all(color: Colors.transparent, width: 3)
            : Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none, // Allow badges to overflow
            children: [
              // Metallic ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.grey.withOpacity(0.2),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueGrey[800],
                  child: Text(
                    player.name.substring(0, 1),
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              if (isDealer)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(1, 1)),
                      ],
                    ),
                    child: const Text("D", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              if (isStartingPlayer)
                Positioned(
                  left: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(1, 1)),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow, size: 16, color: Colors.black),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            player.name,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Text(
              "${player.wonTricks} / ${player.predictedTricks}",
              style: GoogleFonts.robotoMono(
                color: player.wonTricks > player.predictedTricks 
                    ? Colors.redAccent 
                    : (player.wonTricks == player.predictedTricks ? const Color(0xFF4CAF50) : Colors.white),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Score: ${player.score}",
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
