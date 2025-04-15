class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  ChessPiece copyWith({
    PieceType? type,
    PieceColor? color,
    bool? hasMoved,
  }) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  @override
  String toString() {
    return '${color.toString().split('.').last} ${type.toString().split('.').last}';
  }
}

enum PieceType { pawn, rook, knight, bishop, queen, king }
enum PieceColor { white, black }