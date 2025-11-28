enum CardColor {
  BLOOD,   // was RED
  SPIRIT,  // was BLUE
  NATURE,  // was GREEN
  LIGHT,   // was YELLOW
  NONE // For Arcanum/Shadow or when no trump
}

enum CardType {
  NUMBER,
  ARCANUM,  // was WIZARD
  SHADOW    // was JESTER
}

enum PlayerType {
  HUMAN,
  BOT
}

enum GamePhase {
  SETUP,
  BIDDING,
  PLAYING,
  ROUND_OVER,
  GAME_OVER
}

