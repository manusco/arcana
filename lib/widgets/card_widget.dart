import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/card.dart' as game;
import '../models/enums.dart';
import '../services/localization_service.dart';

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
    // Scale factor based on width (default 80)
    final scale = width / 80;
    final fontSize = 16 * scale;
    final suitSize = 14 * scale;
    final centerIconSize = 40 * scale;
    final centerTextSize = 10 * scale;
    final centerSuitSize = 28 * scale;

    final loc = context.read<LocalizationService>();
    String semanticLabel = "";
    if (card.type == CardType.ARCANUM) {
      semanticLabel = loc.translate('a11y_card_arcanum');
    } else if (card.type == CardType.SHADOW) {
      semanticLabel = loc.translate('a11y_card_shadow');
    } else {
      String suitKey = 'suit_${card.color.name.toLowerCase()}';
      String suitName = loc.translate(suitKey);
      semanticLabel = "${card.value} ${loc.translate('card_of')} $suitName";
    }
    
    return Semantics(
      label: semanticLabel,
      button: true,
      hint: onTap != null ? loc.translate('a11y_play_card') : null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: isSelected ? 20 : 0, left: 4, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8 * scale,
              offset: Offset(2 * scale, 4 * scale),
            ),
            if (isSelected)
              BoxShadow(
                color: _cardColor.withValues(alpha: 0.6),
                blurRadius: 12 * scale,
                spreadRadius: 2 * scale,
              ),
          ],
          border: Border.all(color: _cardColor, width: 2 * scale),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10 * scale),
          child: Stack(
            children: [
              // Top Left Corner
              Positioned(
                top: 4 * scale,
                left: 6 * scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cardSymbol,
                      style: GoogleFonts.robotoMono(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: _cardColor,
                        height: 1.0,
                      ),
                    ),
                    if (_suitSymbol.isNotEmpty)
                      Text(
                        _suitSymbol,
                        style: TextStyle(
                          fontSize: suitSize,
                          color: _cardColor,
                          height: 0.9,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Bottom Right Corner (Inverted)
              Positioned(
                bottom: 4 * scale,
                right: 6 * scale,
                child: Transform.rotate(
                  angle: 3.14159,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cardSymbol,
                        style: GoogleFonts.robotoMono(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: _cardColor,
                          height: 1.0,
                        ),
                      ),
                      if (_suitSymbol.isNotEmpty)
                        Text(
                          _suitSymbol,
                          style: TextStyle(
                            fontSize: suitSize,
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
                          Icon(Icons.auto_fix_high, size: centerIconSize, color: _cardColor),
                          SizedBox(height: 2 * scale),
                          if (scale >= 0.7) // Only show text if card is large enough
                            Text(
                              loc.translate('card_arcanum_label'),
                              style: GoogleFonts.cinzel(
                                fontSize: centerTextSize,
                                fontWeight: FontWeight.bold,
                                color: _cardColor,
                                letterSpacing: 1.2 * scale,
                              ),
                            ),
                        ],
                      )
                    : card.type == CardType.SHADOW
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.theater_comedy, size: centerIconSize, color: _cardColor),
                              SizedBox(height: 2 * scale),
                              if (scale >= 0.7) // Only show text if card is large enough
                                Text(
                                  loc.translate('card_shadow_label'),
                                  style: GoogleFonts.cinzel(
                                    fontSize: centerTextSize,
                                    fontWeight: FontWeight.bold,
                                    color: _cardColor,
                                    letterSpacing: 1.2 * scale,
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Large center suit symbols
                              if (_suitSymbol.isNotEmpty && scale >= 0.6)
                                Text(
                                  _suitSymbol * (scale >= 0.8 ? 3 : 2),
                                  style: TextStyle(
                                    fontSize: centerSuitSize,
                                    color: _cardColor.withValues(alpha: 0.3),
                                    letterSpacing: 2 * scale,
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
                      borderRadius: BorderRadius.circular(10 * scale),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }
}
