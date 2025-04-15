import 'package:instavideo/models/game_state.dart';
import 'package:instavideo/services/chess_ai.dart';
import '../models/chess_piece.dart';

class ChessRules {
  static List<Move> getAllValidMoves(GameState state) {
    final moves = <Move>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board[row][col];
        if (piece != null && piece.color == state.currentPlayer) {
          moves.addAll(getValidMovesForPiece(state, row, col));
        }
      }
    }
    return moves;
  }

  static List<Move> getValidMovesForPiece(GameState state, int row, int col) {
    final piece = state.board[row][col];
    if (piece == null) return [];

    final moves = <Move>[];
    switch (piece.type) {
      case PieceType.pawn:
        _addPawnMoves(state, row, col, moves);
        break;
      case PieceType.rook:
        _addRookMoves(state, row, col, moves);
        break;
      case PieceType.knight:
        _addKnightMoves(state, row, col, moves);
        break;
      case PieceType.bishop:
        _addBishopMoves(state, row, col, moves);
        break;
      case PieceType.queen:
        _addQueenMoves(state, row, col, moves);
        break;
      case PieceType.king:
        _addKingMoves(state, row, col, moves);
        break;
    }
    return moves;
  }

  static void _addPawnMoves(GameState state, int row, int col, List<Move> moves) {
    final piece = state.board[row][col]!;
    final direction = piece.color == PieceColor.white ? -1 : 1;

    // Forward move
    if (_isValidSquare(row + direction, col) && state.board[row + direction][col] == null) {
      moves.add(Move(startRow: row, startCol: col, endRow: row + direction, endCol: col));

      // Double move from starting position
      if ((row == 1 && piece.color == PieceColor.black) ||
          (row == 6 && piece.color == PieceColor.white)) {
        if (state.board[row + 2 * direction][col] == null) {
          moves.add(Move(startRow: row, startCol: col, endRow: row + 2 * direction, endCol: col));
        }
      }
    }

    // Captures
    for (final captureCol in [col - 1, col + 1]) {
      if (_isValidSquare(row + direction, captureCol)) {
        final targetPiece = state.board[row + direction][captureCol];
        if (targetPiece != null && targetPiece.color != piece.color) {
          moves.add(Move(startRow: row, startCol: col, endRow: row + direction, endCol: captureCol));
        }
      }
    }
  }
  static bool isCheckmate(GameState gameState) {
    final currentColor = gameState.currentPlayer;

    // Find the king's position
    int kingRow = -1, kingCol = -1;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = gameState.board[row][col];
        if (piece != null && piece.type == PieceType.king && piece.color == currentColor) {
          kingRow = row;
          kingCol = col;
          break;
        }
      }
    }

    // If king is not found, return false (should not happen)
    if (kingRow == -1 || kingCol == -1) return false;

    // Check if the king is currently in check
    if (!_isSquareUnderAttack(gameState, kingRow, kingCol, currentColor)) {
      return false; // King is not in check
    }

    // Check for any legal moves
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = gameState.board[row][col];
        if (piece != null && piece.color == currentColor) {
          final possibleMoves = getValidMovesForPiece(gameState, row, col);
          for (final move in possibleMoves) {
            final simulatedState = makeMove(gameState, move);
            if (!_isSquareUnderAttack(simulatedState, kingRow, kingCol, currentColor)) {
              return false; // A valid escape move exists
            }
          }
        }
      }
    }

    // If no legal moves left and king is in check => checkmate
    return true;
  }
  static bool _isSquareUnderAttack(GameState gameState, int row, int col, PieceColor color) {
    final board = gameState.board;
    final opponentColor = color == PieceColor.white ? PieceColor.black : PieceColor.white;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == opponentColor) {
          final moves = getValidMovesForPiece(gameState, r, c);
          for (final move in moves) {
            if (move.endRow == row && move.endCol == col) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  static void _addRookMoves(GameState state, int row, int col, List<Move> moves) {
    _addStraightMoves(state, row, col, moves);
  }

  static void _addKnightMoves(GameState state, int row, int col, List<Move> moves) {
    final piece = state.board[row][col]!;
    const knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ];

    for (final move in knightMoves) {
      final newRow = row + move[0];
      final newCol = col + move[1];
      if (_isValidSquare(newRow, newCol)) {
        final targetPiece = state.board[newRow][newCol];
        if (targetPiece == null || targetPiece.color != piece.color) {
          moves.add(Move(startRow: row, startCol: col, endRow: newRow, endCol: newCol));
        }
      }
    }
  }

  static void _addBishopMoves(GameState state, int row, int col, List<Move> moves) {
    _addDiagonalMoves(state, row, col, moves);
  }

  static void _addQueenMoves(GameState state, int row, int col, List<Move> moves) {
    _addStraightMoves(state, row, col, moves);
    _addDiagonalMoves(state, row, col, moves);
  }

  static void _addKingMoves(GameState state, int row, int col, List<Move> moves) {
    final piece = state.board[row][col]!;
    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
        if ((r != row || c != col) && _isValidSquare(r, c)) {
          final targetPiece = state.board[r][c];
          if (targetPiece == null || targetPiece.color != piece.color) {
            moves.add(Move(startRow: row, startCol: col, endRow: r, endCol: c));
          }
        }
      }
    }
  }
  static bool isStalemate(GameState state) {
    // If the current player is in check, it cannot be stalemate
    if (isInCheck(state, state.currentPlayer)) {
      return false;
    }

    // Get all valid moves for the current player
    final validMoves = getAllValidMoves(state);
    return validMoves.isEmpty; // If no valid moves, it's stalemate
  }
  static void _addStraightMoves(GameState state, int row, int col, List<Move> moves) {
    final piece = state.board[row][col]!;
    const directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],
    ];

    for (final dir in directions) {
      for (int i = 1; i < 8; i++) {
        final newRow = row + dir[0] * i;
        final newCol = col + dir[1] * i;
        if (!_isValidSquare(newRow, newCol)) break;

        final targetPiece = state.board[newRow][newCol];
        if (targetPiece == null) {
          moves.add(Move(startRow: row, startCol: col, endRow: newRow, endCol: newCol));
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(Move(startRow: row, startCol: col, endRow: newRow, endCol: newCol));
          }
          break;
        }
      }
    }
  }

  static void _addDiagonalMoves(GameState state, int row, int col, List<Move> moves) {
    final piece = state.board[row][col]!;
    const directions = [
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ];

    for (final dir in directions) {
      for (int i = 1; i < 8; i++) {
        final newRow = row + dir[0] * i;
        final newCol = col + dir[1] * i;
        if (!_isValidSquare(newRow, newCol)) break;

        final targetPiece = state.board[newRow][newCol];
        if (targetPiece == null) {
          moves.add(Move(startRow: row, startCol: col, endRow: newRow, endCol: newCol));
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(Move(startRow: row, startCol: col, endRow: newRow, endCol: newCol));
          }
          break;
        }
      }
    }
  }

  static bool _isValidSquare(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  static GameState makeMove(GameState state, Move move) {
    final newBoard = List.generate(8, (i) => List<ChessPiece?>.from(state.board[i]));
    final piece = newBoard[move.startRow][move.startCol]!;

    // Handle pawn promotion
    if (piece.type == PieceType.pawn &&
        (move.endRow == 0 || move.endRow == 7)) {
      final promotedPiece = move.promotion ?? PieceType.queen;
      newBoard[move.endRow][move.endCol] = ChessPiece(
        type: promotedPiece,
        color: piece.color,
        hasMoved: true,
      );
    } else {
      newBoard[move.endRow][move.endCol] = piece.copyWith(hasMoved: true);
    }

    newBoard[move.startRow][move.startCol] = null;

    return state.copyWith(
      board: newBoard,
      currentPlayer: state.currentPlayer == PieceColor.white
          ? PieceColor.black
          : PieceColor.white,
      selectedSquare: null,
      validMoves: [],
    );
  }

  static bool isInCheck(GameState state, PieceColor color) {
    int kingRow = -1, kingCol = -1;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board[row][col];
        if (piece is ChessPiece && piece.type == PieceType.king && piece.color == color) {
          kingRow = row;
          kingCol = col;
          break;
        }
      }
    }

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board[row][col];
        if (piece != null && piece.color != color) {
          final validMoves = getValidMovesForPiece(state, row, col);
          if (validMoves.any((move) => move.endRow == kingRow && move.endCol == kingCol)) {
            return true; // The king is in check
          }
        }
      }
    }
    return false; // The king is not in check
  }


  static bool hasAnyValidMoves(GameState state) {
    // Check all pieces of current player for any valid moves
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board[row][col];
        if (piece != null && piece.color == state.currentPlayer) {
          final moves = getValidMovesForPiece(state, row, col);
          if (moves.isNotEmpty) return true;
        }
      }
    }
    return false;
  }
}