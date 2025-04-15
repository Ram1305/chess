import 'package:flutter/material.dart';
// import 'package:chess_game/ui/screens/game_screen.dart';
// import 'package:chess_game/ui/screens/online_lobby.dart';
// import 'package:chess_game/models/game_state.dart';
import 'package:instavideo/models/game_state.dart';
import 'package:instavideo/ui/online_lobby.dart' show OnlineLobby;

import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GameScreen(
                          mode: GameMode.vsComputer,
                          gameState: GameState(
                            board: [], // Provide a valid board instance
                            mode: GameMode.vsComputer, // Provide a valid mode
                          ), // Provide a valid GameState instance
                        ),
                  ),
                );
              },
              child: const Text('Play vs Computer'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GameScreen(
                          mode: GameMode.localMultiplayer,
                          gameState: GameState(
                            board: [], // Provide a valid board instance
                            mode:
                                GameMode
                                    .localMultiplayer, // Provide the correct mode
                          ),
                        ),
                  ),
                );
              },
              child: const Text('Local Multiplayer'),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnlineLobby()),
                );
              },
              child: const Text('Online Multiplayer'),
            ),
          ],
        ),
      ),
    );
  }
}
