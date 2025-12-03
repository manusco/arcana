# Arcana: The Game of Prophecy - Design & Instruction Document

## 1. Game Idea
**Arcana** is a strategic trick-taking card game set in a mystical realm where foresight is as powerful as brute force. Unlike traditional card games where the goal is simply to win the most tricks, Arcana challenges players to **predict** exactly how many tricks they will win. 

The game combines the classic mechanics of trick-taking with a betting system ("The Prophecy"), rewarding precision and punishing hubris. It is designed to be accessible yet deeply strategic, appealing to casual players and hardcore strategists alike.

## 2. Game Mechanics

### The Deck
The deck consists of **60 cards**:
*   **52 Suit Cards**: 4 Suits, numbered 1-13.
    *   **Blood** (Red)
    *   **Spirit** (Blue)
    *   **Nature** (Green)
    *   **Light** (Yellow)
*   **4 Arcanum Cards (A)**: The ultimate power.
*   **4 Shadow Cards (S)**: The void.

### The Rules

#### 1. The Deal
The game is played over a series of rounds.
*   **Round 1**: Each player receives 1 card.
*   **Round 2**: Each player receives 2 cards.
*   ...and so on, until the final round where the entire deck is dealt.

#### 2. The Trump
At the start of each round (except the final round if no cards remain), the top card of the remaining deck is flipped to determine the **Trump Suit**.
*   If an **Arcanum** is flipped, the dealer chooses the Trump suit.
*   If a **Shadow** is flipped, there is **No Trump** for that round.

#### 3. The Prophecy (Bidding)
After looking at their hand and the Trump card, players must announce their **Prophecy**: the exact number of tricks they plan to win that round.
*   Bidding proceeds clockwise starting from the player to the left of the dealer.
*   The total number of bids *cannot* equal the total number of tricks available in the round (optional "Hook" rule to ensure someone fails), though standard play may allow it.

#### 4. The Action (Play)
The player to the left of the dealer leads the first trick. Play proceeds clockwise.
*   **Must Follow Suit**: Players must play a card of the same suit as the lead card if they have one.
*   **Exceptions**: Arcanum and Shadow cards can be played at any time, regardless of suit.
*   **Winning the Trick**:
    1.  **Arcanum**: The first Arcanum played wins the trick.
    2.  **Trump**: If no Arcanum is played, the highest Trump card wins.
    3.  **Lead Suit**: If no Arcanum or Trump is played, the highest card of the lead suit wins.
    4.  **Shadow**: Shadows always lose (unless the trick is composed entirely of Shadows, in which case the first Shadow wins).

#### 5. Scoring
At the end of the round, scores are tallied based on the accuracy of the Prophecy.
*   **Success (Correct Prophecy)**: 
    *   **20 Points** (Base)
    *   **+10 Points** per trick won.
*   **Failure (Incorrect Prophecy)**:
    *   **-10 Points** for every trick difference (above or below the bid).

## 3. Game Focus
*   **Precision over Power**: Having a hand full of high cards is useless if you bid low. The core skill is hand evaluation and adaptability.
*   **Risk Management**: Players must decide whether to play safe or bid aggressively.
*   **Psychology**: Reading opponents' bids to infer their hand strength.

## 4. Design Style
The aesthetic of Arcana is **Mystical, Premium, and Atmospheric**.

*   **Visual Theme**: Dark fantasy, tarot-inspired.
*   **Color Palette**:
    *   **Backgrounds**: Deep charcoal, obsidian, midnight blue.
    *   **Accents**: Neon/Glowing versions of the suit colors (Crimson, Cyan, Emerald, Amber).
    *   **UI Elements**: Glassmorphism (frosted glass effects), thin borders, glowing text.
*   **Typography**: 
    *   Headings: Serif fonts with a magical feel (e.g., Cinzel, Playfair Display).
    *   Body: Clean, readable Sans-Serif (e.g., Inter, Roboto).
*   **Animations**:
    *   Smooth card dealing and flipping animations.
    *   Particle effects for Arcanum/Trump plays.
    *   Subtle pulsing glows for active elements.

## 5. Tech Stack
The project is built using **Flutter** for cross-platform compatibility (Web, Windows, Android, iOS).

*   **Core Framework**: Flutter (Dart SDK >= 3.10.1)
*   **State Management**: `provider` (Simple, scalable state management for game logic).
*   **Persistence**: `shared_preferences` (For saving high scores, player names, and settings).
*   **Styling/Fonts**: `google_fonts` (Dynamic font loading).
*   **Animation**: `flutter_animate` (Declarative animations for UI and game actions).
*   **Icons**: `cupertino_icons` & Material Icons.

## 6. Testing Strategy
Quality assurance is critical for maintaining the logic integrity of the game.

*   **Unit Testing (`flutter_test`)**:
    *   Verify scoring algorithms (Success/Fail cases).
    *   Test card comparison logic (Arcanum > Trump > Lead > Off-suit).
    *   Test deck generation and shuffling fairness.
*   **Widget Testing**:
    *   Ensure UI components (Scoreboard, Hand view) render correctly with various states.
    *   Test responsiveness on different screen sizes (Mobile vs Desktop).
*   **Integration Testing**:
    *   Simulate full game loops (Deal -> Bid -> Play -> Score).
    *   Verify state persistence across app restarts.

## 7. Deployment
The game is designed to be deployed to multiple platforms.

*   **Web**:
    *   Command: `flutter build web --release`
    *   Target: PWA (Progressive Web App) for easy access via browser.
*   **Windows**:
    *   Command: `flutter build windows`
    *   Distribution: Standalone `.exe` or Microsoft Store.
*   **Mobile (Android/iOS)**:
    *   Standard Flutter build pipelines (`flutter build apk`, `flutter build ipa`).

---
*Note: This document serves as the single source of truth for the game design and mechanics of Arcana.*
