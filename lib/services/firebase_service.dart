import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:instavideo/models/chess_piece.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String userId = const Uuid().v4(); // Simple way to generate unique ID
  late DatabaseReference _gameRef;
  late StreamSubscription _gameSubscription;
  DatabaseReference get database => _database;
  Future<String> createOnlineGame() async {
    final gameId = const Uuid().v4();
    await _database.child('games/$gameId').set({
      'whitePlayerId': userId,
      'blackPlayerId': null,
      'currentPlayer': 'white',
      'board': _serializeBoard(_initializeBoard()),
      'status': 'waiting',
      'createdAt': ServerValue.timestamp,
    });
    return gameId;
  }

  Future<void> joinOnlineGame(String gameId) async {
    await _database.child('games/$gameId').update({
      'blackPlayerId': userId,
      'status': 'playing',
    });
  }

  void listenToGame(String gameId, Function(GameState) onUpdate) {
    _gameRef = _database.child('games/$gameId');
    _gameSubscription = _gameRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final gameState = _parseGameState(data);
        onUpdate(gameState);
      }
    });
  }

  Future<void> updateGameState(String gameId, GameState state) async {
    await _database.child('games/$gameId').update({
      'board': _serializeBoard(state.board),
      'currentPlayer': state.currentPlayer.toString().split('.').last,
      'status': state.status.toString().split('.').last,
    });
  }

  void cancelGameListeners() {
    _gameSubscription.cancel();
  }

  GameState _parseGameState(Map<dynamic, dynamic> data) {
    return GameState(
      board: _parseBoard(data['board']),
      currentPlayer: data['currentPlayer'] == 'white'
          ? PieceColor.white
          : PieceColor.black,
      status: _parseStatus(data['status']),
      mode: GameMode.onlineMultiplayer,
      whitePlayerId: data['whitePlayerId'],
      blackPlayerId: data['blackPlayerId'],
      gameId: data['key'],
      isOnline: true,
    );
  }

  List<List<ChessPiece?>> _parseBoard(dynamic boardData) {
    // Implement board parsing from Firebase format
    // This is a simplified version - you'll need to expand it
    return List.generate(8, (i) => List.filled(8, null));
  }

  String _serializeBoard(List<List<ChessPiece?>> board) {
    // Implement board serialization for Firebase
    // This should match your parsing logic
    return board.toString();
  }

  GameStatus _parseStatus(String status) {
    switch (status) {
      case 'check': return GameStatus.check;
      case 'checkmate': return GameStatus.checkmate;
      case 'stalemate': return GameStatus.stalemate;
      case 'draw': return GameStatus.draw;
      default: return GameStatus.playing;
    }
  }

  List<List<ChessPiece?>> _initializeBoard() {
    // Same initialization as before
    return List.generate(8, (i) => List.filled(8, null));
  }
}