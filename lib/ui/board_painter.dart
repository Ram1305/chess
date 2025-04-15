import 'package:flutter/material.dart';

import 'package:instavideo/models/chess_piece.dart';
import 'package:instavideo/ui/theme.dart';

class BoardPainter extends CustomPainter {
  final List<List<ChessPiece?>> board;
  final String? selectedSquare;
  final List<String> validMoves;
  final bool flipped;

  BoardPainter({
    required this.board,
    this.selectedSquare,
    this.validMoves = const [],
    this.flipped = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 8;
    final lightPaint = Paint()..color = ChessTheme.lightSquareColor;
    final darkPaint = Paint()..color = ChessTheme.darkSquareColor;
    final selectedPaint = Paint()..color = Colors.blue.withOpacity(0.5);
    final validMovePaint = Paint()..color = Colors.blue.withOpacity(0.3);

    // Draw board
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final displayRow = flipped ? 7 - row : row;
        final displayCol = flipped ? 7 - col : col;

        final rect = Rect.fromLTWH(
          displayCol * cellSize,
          displayRow * cellSize,
          cellSize,
          cellSize,
        );

        // Draw square
        if ((row + col) % 2 == 0) {
          canvas.drawRect(rect, lightPaint);
        } else {
          canvas.drawRect(rect, darkPaint);
        }

        // Highlight selected square
        if (selectedSquare != null &&
            selectedSquare == '${String.fromCharCode(97 + col)}${8 - row}') {
          canvas.drawRect(rect, selectedPaint);
        }

        // Highlight valid moves
        if (validMoves.contains('${String.fromCharCode(97 + col)}${8 - row}')) {
          canvas.drawCircle(
            Offset(rect.center.dx, rect.center.dy),
            cellSize / 4,
            validMovePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}