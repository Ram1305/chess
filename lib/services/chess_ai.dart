import 'dart:math';
import 'package:instavideo/models/chess_piece.dart';
import 'package:instavideo/models/game_state.dart';
import 'package:instavideo/utils/chess_rules.dart';

class ChessAI {
  static Move getRandomMove(GameState state) {
    final validMoves = ChessRules.getAllValidMoves(state);
    if (validMoves.isEmpty) {
      throw Exception('No valid moves available');
    }
    final random = Random();
    return validMoves[random.nextInt(validMoves.length)];
  }

  static Move getBestMove(GameState state) {
    final validMoves = ChessRules.getAllValidMoves(state);

    // Prioritize captures
    final captureMoves = validMoves.where((move) {
      return state.board[move.endRow][move.endCol] != null;
    }).toList();

    if (captureMoves.isNotEmpty) {
      // Sort by captured piece value
      captureMoves.sort((a, b) {
        final aPiece = state.board[a.endRow][a.endCol];
        final bPiece = state.board[b.endRow][b.endCol];
        return _pieceValue(bPiece) - _pieceValue(aPiece);
      });
      return captureMoves.first;
    }

    // If no captures, return random move
    if (validMoves.isEmpty) {
      throw Exception('No valid moves available');
    }
    return getRandomMove(state);
  }

  static int _pieceValue(ChessPiece? piece) {
    if (piece == null) return 0;
    switch (piece.type) {
      case PieceType.pawn: return 1;
      case PieceType.knight: return 3;
      case PieceType.bishop: return 3;
      case PieceType.rook: return 5;
      case PieceType.queen: return 9;
      case PieceType.king: return 0; // King capture is handled elsewhere
    }
  }
}

class Move {
  final int startRow, startCol, endRow, endCol;
  final PieceType? promotion;

  Move({
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
    this.promotion,
  });

  @override
  String toString() {
    return 'Move from ($startRow, $startCol) to ($endRow, $endCol)${promotion !=
        null ? ' with promotion to $promotion' : ''}';
  }}