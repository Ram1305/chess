// import 'package:chess_game/models/chess_piece.dart';

import 'chess_piece.dart';

class GameState {
  final List<List<ChessPiece?>> board;
  final PieceColor currentPlayer;
  final String? selectedSquare;
  final List<String> validMoves;
  final GameStatus status;
  final GameMode mode;
  final String? whitePlayerId;
  final String? blackPlayerId;
  final String? gameId;
  final bool isOnline;

  GameState({
    required this.board,
    this.currentPlayer = PieceColor.white,
    this.selectedSquare,
    this.validMoves = const [],
    this.status = GameStatus.playing,
    required this.mode,
    this.whitePlayerId,
    this.blackPlayerId,
    this.gameId,
    this.isOnline = false,
  });

  GameState copyWith({
    List<List<ChessPiece?>>? board,
    PieceColor? currentPlayer,
    String? selectedSquare,
    List<String>? validMoves,
    GameStatus? status,
    GameMode? mode,
    String? whitePlayerId,
    String? blackPlayerId,
    String? gameId,
    bool? isOnline,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      selectedSquare: selectedSquare ?? this.selectedSquare,
      validMoves: validMoves ?? this.validMoves,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      whitePlayerId: whitePlayerId ?? this.whitePlayerId,
      blackPlayerId: blackPlayerId ?? this.blackPlayerId,
      gameId: gameId ?? this.gameId,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

enum GameStatus { playing, check, checkmate, stalemate, draw }
enum GameMode { vsComputer, localMultiplayer, onlineMultiplayer }