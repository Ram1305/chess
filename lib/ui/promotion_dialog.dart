import 'package:flutter/material.dart';

import 'package:instavideo/ui/piece_widget.dart';

import '../models/chess_piece.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final Function(PieceType) onSelected;

  const PromotionDialog({
    super.key,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Promote Pawn To'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPromotionOption(PieceType.queen, context),
          _buildPromotionOption(PieceType.rook, context),
          _buildPromotionOption(PieceType.bishop, context),
          _buildPromotionOption(PieceType.knight, context),
        ],
      ),
    );
  }

  Widget _buildPromotionOption(PieceType type, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onSelected(type);
      },
      child: PieceWidget(
        piece: ChessPiece(type: type, color: color),
        size: 50,
      ),
    );
  }
}