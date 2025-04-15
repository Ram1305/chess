import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../services/firebase_service.dart';
import 'game_screen.dart';

class OnlineLobby extends StatefulWidget {
  const OnlineLobby({super.key});

  @override
  State<OnlineLobby> createState() => _OnlineLobbyState();
}

class _OnlineLobbyState extends State<OnlineLobby> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _gameIdController = TextEditingController();
  List<Map<String, dynamic>> _availableGames = [];
  late StreamSubscription _gamesSubscription;

  @override
  void initState() {
    super.initState();
    _listenForGames();
  }

  @override
  void dispose() {
    _gameIdController.dispose();
    _gamesSubscription.cancel();
    super.dispose();
  }

  void _listenForGames() {
    _gamesSubscription = _firebaseService.database.child('games')
        .orderByChild('status')
        .equalTo('waiting')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final gamesMap = event.snapshot.value as Map<dynamic, dynamic>;
        print('Available games: $gamesMap'); // Debug print
        setState(() {
          _availableGames = gamesMap.entries.map((entry) {
            return {
              'id': entry.key,
              'createdAt': entry.value['createdAt'],
            };
          }).toList();
        });
      } else {
        print('No games available'); // Debug print
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Chess Lobby')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _createGame,
              child: const Text('Create New Game'),
            ),
            const SizedBox(height: 20),
            const Text('OR', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Join Existing Game', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _gameIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Game ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _joinGameById,
              child: const Text('Join Game by ID'),
            ),
            const SizedBox(height: 20),
            const Text('Available Games', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: _availableGames.isEmpty
                  ? const Center(child: Text('No games available'))
                  : ListView.builder(
                itemCount: _availableGames.length,
                itemBuilder: (context, index) {
                  final game = _availableGames[index];
                  return ListTile(
                    title: Text('Game ${game['id']}'),
                    subtitle: Text('Created ${_formatDate(game['createdAt'])}'),
                    trailing: ElevatedButton(
                      onPressed: () => _joinGame(game['id']),
                      child: const Text('Join'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'recently';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _createGame() async {
    try {
      final gameId = await _firebaseService.createOnlineGame();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            mode: GameMode.onlineMultiplayer,
            gameState: GameState(
              board: _initializeBoard(),
              mode: GameMode.onlineMultiplayer,
              whitePlayerId: _firebaseService.userId,
              gameId: gameId,
              isOnline: true,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    }
  }

  Future<void> _joinGameById() async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a game ID')),
      );
      return;
    }
    await _joinGame(gameId);
  }

  Future<void> _joinGame(String gameId) async {
    try {
      await _firebaseService.joinOnlineGame(gameId);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            mode: GameMode.onlineMultiplayer,
            gameState: GameState(
              board: _initializeBoard(),
              mode: GameMode.onlineMultiplayer,
              blackPlayerId: _firebaseService.userId,
              gameId: gameId,
              isOnline: true,
              currentPlayer: PieceColor.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining game: $e')),
      );
    }
  }

  List<List<ChessPiece?>> _initializeBoard() {
    // Same initialization as before
    return List.generate(8, (i) => List.filled(8, null));
  }
}