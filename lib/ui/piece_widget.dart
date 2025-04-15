import 'package:flutter/material.dart';

import 'package:instavideo/ui/theme.dart';

import '../models/chess_piece.dart';

class PieceWidget extends StatelessWidget {
  final ChessPiece? piece;
  final double size;
  final bool isDragging;

  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    if (piece == null) return SizedBox(width: size, height: size);

    final color = piece!.color == PieceColor.white
        ? ChessTheme.whitePieceColor
        : ChessTheme.blackPieceColor;

    String pieceSymbol;
    switch (piece!.type) {
      case PieceType.king:
        pieceSymbol = piece!.color == PieceColor.white ? '♔' : '♚';
        break;
      case PieceType.queen:
        pieceSymbol = piece!.color == PieceColor.white ? '♕' : '♛';
        break;
      case PieceType.rook:
        pieceSymbol = piece!.color == PieceColor.white ? '♖' : '♜';
        break;
      case PieceType.bishop:
        pieceSymbol = piece!.color == PieceColor.white ? '♗' : '♝';
        break;
      case PieceType.knight:
        pieceSymbol = piece!.color == PieceColor.white ? '♘' : '♞';
        break;
      case PieceType.pawn:
        pieceSymbol = piece!.color == PieceColor.white ? '♙' : '♟';
        break;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Text(
        pieceSymbol,
        style: TextStyle(
          color: color,
          fontSize: size * 0.8,
          shadows: isDragging
              ? [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]
              : null,
        ),
      ),
    );
  }
}