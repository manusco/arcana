import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/card.dart' as game;
import '../models/enums.dart';

class CardWidget extends StatelessWidget {
  final game.Card card;
  final VoidCallback? onTap;
  final bool isSelected;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.isSelected = false,
    this.width = 80,
    this.height = 120,
  });

  Color get _cardColor {
    switch (card.color) {
      case CardColor.BLOOD: return const Color(0xFFD32F2F);
      case CardColor.SPIRIT: return const Color(0xFF1976D2);
      case CardColor.NATURE: return const Color(0xFF388E3C);
      case CardColor.LIGHT: return const Color(0xFFFFA000);
      case CardColor.NONE:
        if (card.type == CardType.ARCANUM) return const Color(0xFF7B1FA2); // Purple
        if (card.type == CardType.SHADOW) return const Color(0xFF616161); // Grey
        return Colors.black;
    }
  }

  String get _cardSymbol {
    switch (card.type) {
      case CardType.ARCANUM: return "A";
      case CardType.SHADOW: return "S";
      case CardType.NUMBER: return card.value.toString();
    }
  }

  String get _suitSymbol {
    switch (card.color) {
      case CardColor.BLOOD: return "♥";
      case CardColor.SPIRIT: return "♠";
      case CardColor.NATURE: return "♣";
      case CardColor.LIGHT: return "♦";
      case CardColor.NONE: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: isSelected ? 20 : 0, left: 4, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: _cardColor.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(color: _cardColor, width: 2),
        ),
        child: Stack(
          children: [
            // Top Left Corner
            Positioned(
              top: 6,
              left: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _cardSymbol,
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _cardColor,
                    ),
                  ),
                  if (_suitSymbol.isNotEmpty)
                    Text(
                      _suitSymbol,
                      style: TextStyle(
                        fontSize: 14,
                        color: _cardColor,
                        height: 0.9,
                      ),
                    ),
                ],
              ),
            ),
            
            // Bottom Right Corner (Inverted)
            Positioned(
              bottom: 6,
              right: 8,
              child: Transform.rotate(
                angle: 3.14159,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _cardSymbol,
                      style: GoogleFonts.robotoMono(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _cardColor,
                      ),
                    ),
                    if (_suitSymbol.isNotEmpty)
                      Text(
                        _suitSymbol,
                        style: TextStyle(
                          fontSize: 14,
                          color: _cardColor,
                          height: 0.9,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Center Design
            Center(
              child: card.type == CardType.ARCANUM
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_fix_high, size: 40, color: _cardColor),
                        const SizedBox(height: 4),
                        Text(
                          "ARCANUM",
                          style: GoogleFonts.cinzel(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _cardColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    )
                  : card.type == CardType.SHADOW
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.theater_comedy, size: 40, color: _cardColor),
                            const SizedBox(height: 4),
                            Text(
                              "SHADOW",
                              style: GoogleFonts.cinzel(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _cardColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Large center suit symbols
                            if (_suitSymbol.isNotEmpty)
                              Text(
                                _suitSymbol * 3,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: _cardColor.withOpacity(0.3),
                                  letterSpacing: 2,
                                ),
                              ),
                          ],
                        ),
            ),
            
            // Subtle gradient overlay for depth
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }
}
