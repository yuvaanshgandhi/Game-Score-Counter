# Game Score Counter

A modern, fluid iOS application built with SwiftUI to track player scores, rounds, and game statistics. Originally designed as a Yaniv scoreboard, it is now generalized to support presets for multiple card and board games, including **Yaniv**, **Hearts**, **Uno**, and **Gin Rummy**, with support for custom games.

---

## 🌟 Key Features

- 🎮 **Multiple Game Presets**: Out-of-the-box configurations for popular games:
  - **Yaniv**: Standard scoring rules with configurable target scores (e.g., first to 50/100/150 loses) and custom score halving/reset mechanisms.
  - **Hearts**: Score accumulation tracker with standard termination thresholds.
  - **Uno**: Score accumulation with clean, simple entry.
  - **Gin Rummy**: Track scores round-by-round to target limits.
- ⚡ **Custom Presets**: Create your own game rules (starting scores, termination thresholds, scoring behavior).
- 🔄 **Ongoing Games & History**: Pause any ongoing game and resume it later, or view a history of all completed games with detailed scoreboard views.
- 📊 **Player Statistics**: Tracks lifetime player performance, win rates, average round scores, and game histories.
- 🎨 **Premium Modern UI**: Glassmorphic interfaces, smooth transitions, custom visual cues, and native Apple haptic feedback integration.

---

## 📁 Architecture & File Structure

The project follows a clean architectural layout:

- **App Entry**:
  - `Game_Score_CounterApp.swift`: Main app initialization and context setup.
- **Models & Logic**:
  - `Models.swift`: Core data structures representing players, presets, ongoing games, and score history.
  - `GameManager.swift`: State engine managing current active games, round inputs, score recalculations, and serialization/deserialization to UserDefaults.
  - `PlayerManager.swift`: Handles player rosters, profiles, and statistics persistence.
- **Views**:
  - `WelcomeView.swift`: Splash landing screen to set up a new game, configure players, select game presets, or manage rosters.
  - `ScoreboardView.swift`: The main active scoreboard interface listing current player totals, round logs, and current standings.
  - `AddRoundView.swift`: Input panel to quickly log scores for all players at the end of each round.
  - `HistoryView.swift`: Archives of completed games.
  - `OngoingGamesView.swift`: Directory of suspended games that can be resumed.
  - `StatisticsView.swift`: Overview of player stats, win ratios, and game records.
  - `WinnerView.swift`: Celebration screen shown upon game completion.
  - `UIComponents.swift`: Reusable custom SwiftUI widgets.
- **Helpers**:
  - `HapticHelper.swift`: System wrapper for physical feedback prompts.

---

## ⚙️ Building & Running the Project

### Prerequisites
- macOS Sequoia (or matching version supporting SwiftUI and Swift 6+)
- Xcode 16.0+
- iOS 17.0+ Simulator/Device target

### Instructions
1. Open the project root folder in Finder:
   ```bash
   cd "Yaniv Counter" # Workspace directory
   cd "Yaniv Counter" # Repository directory (renamed to Game Score Counter)
   ```
2. Open `Game Score Counter.xcodeproj` directly in Xcode.
3. Choose your preferred target device (e.g., iPhone 15 simulator) in the Xcode run bar.
4. Press `Cmd + R` to compile and launch the application.

---

## 🧪 Running Unit & UI Tests

Unit and UI tests are configured inside the project:
- **Unit Tests**: Open the Test Navigator (`Cmd + 6`) and run the test suite under the `Game Score CounterTests` bundle.
- **UI Tests**: Test target `Game Score CounterUITests` verifies interface layouts and round insertion flows.
