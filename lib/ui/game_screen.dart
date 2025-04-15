import 'package:flutter/material.dart';
import 'package:instavideo/models/chess_piece.dart';
import 'package:instavideo/models/game_state.dart';
import 'package:instavideo/ui/piece_widget.dart';
import 'package:instavideo/ui/promotion_dialog.dart';
import 'package:instavideo/utils/chess_rules.dart';

import '../services/chess_ai.dart';
import '../services/firebase_service.dart' show FirebaseService;
import 'board_painter.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final GameState gameState;

  const GameScreen({
    super.key,
    required this.mode,
    required this.gameState,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late FirebaseService _firebaseService;
  String? _draggedPiecePosition;
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _initializeGame();

    if (widget.gameState.isOnline) {
      _firebaseService.listenToGame(
        widget.gameState.gameId!,
        _handleGameUpdate,
      );
    }
  }

  @override
  void dispose() {
    if (widget.gameState.isOnline) {
      _firebaseService.cancelGameListeners();
    }
    super.dispose();
  }

  void _handleGameUpdate(GameState updatedState) {
    if (!mounted) return;

    setState(() {
      _gameState = updatedState;

      // If playing vs computer and it's now computer's turn
      if (widget.mode == GameMode.vsComputer &&
          _gameState.currentPlayer == PieceColor.black &&
          _gameState.status == GameStatus.playing) {
        _makeComputerMove();
      }
    });
  }

  void _initializeGame() {
    _gameState = widget.gameState.copyWith(
      board: widget.gameState.board.isNotEmpty
          ? widget.gameState.board
          : _initializeBoard(),
    );

    // If playing vs computer and computer is first, make a move
    if (widget.mode == GameMode.vsComputer &&
        _gameState.currentPlayer == PieceColor.black &&
        _gameState.status == GameStatus.playing) {
      _makeComputerMove();
    }
  }

  List<List<ChessPiece?>> _initializeBoard() {
    final board = List.generate(8, (i) => List<ChessPiece?>.filled(8, null));

    // Pawns
    for (int col = 0; col < 8; col++) {
      board[1][col] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      board[6][col] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }

    // Rooks
    board[0][0] = ChessPiece(type: PieceType.rook, color: PieceColor.black);
    board[0][7] = ChessPiece(type: PieceType.rook, color: PieceColor.black);
    board[7][0] = ChessPiece(type: PieceType.rook, color: PieceColor.white);
    board[7][7] = ChessPiece(type: PieceType.rook, color: PieceColor.white);

    // Knights
    board[0][1] = ChessPiece(type: PieceType.knight, color: PieceColor.black);
    board[0][6] = ChessPiece(type: PieceType.knight, color: PieceColor.black);
    board[7][1] = ChessPiece(type: PieceType.knight, color: PieceColor.white);
    board[7][6] = ChessPiece(type: PieceType.knight, color: PieceColor.white);

    // Bishops
    board[0][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    board[0][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    board[7][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.white);
    board[7][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.white);

    // Queens
    board[0][3] = ChessPiece(type: PieceType.queen, color: PieceColor.black);
    board[7][3] = ChessPiece(type: PieceType.queen, color: PieceColor.white);

    // Kings
    board[0][4] = ChessPiece(type: PieceType.king, color: PieceColor.black);
    board[7][4] = ChessPiece(type: PieceType.king, color: PieceColor.white);

    return board;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getGameTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: _handleDragEnd,
            child: CustomPaint(
              painter: BoardPainter(
                board: _gameState.board,
                selectedSquare: _gameState.selectedSquare,
                validMoves: _gameState.validMoves,
                flipped: widget.mode == GameMode.vsComputer &&
                    _gameState.currentPlayer == PieceColor.black,
              ),
              child: Stack(
                children: _buildPieces(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGameTitle() {
    switch (widget.mode) {
      case GameMode.vsComputer:
        return ' Computer - ${_gameState.currentPlayer == PieceColor.white ? "Your Turn" : "Computer Thinking..."}';
      case GameMode.localMultiplayer:
        return 'multi - ${_gameState.currentPlayer == PieceColor.white ? "White's Turn" : "Black's Turn"}';
      case GameMode.onlineMultiplayer:
        return 'Online  - ${_gameState.currentPlayer == PieceColor.white ? "White's Turn" : "Black's Turn"}';
    }
  }

  List<Widget> _buildPieces() {
    final widgets = <Widget>[];
    final cellSize = MediaQuery.of(context).size.width / 8;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _gameState.board[row][col];
        final position = '${String.fromCharCode(97 + col)}${8 - row}';

        if (piece != null && position != _draggedPiecePosition) {
          widgets.add(
            Positioned(
              left: col * cellSize,
              top: row * cellSize,
              width: cellSize,
              height: cellSize,
              child: PieceWidget(
                piece: piece,
                size: cellSize,
              ),
            ),
          );
        }
      }
    }

    if (_draggedPiecePosition != null && _dragOffset != null) {
      final col = _draggedPiecePosition!.codeUnitAt(0) - 97;
      final row = 8 - int.parse(_draggedPiecePosition!.substring(1));
      final piece = _gameState.board[row][col];

      if (piece != null) {
        widgets.add(
          Positioned(
            left: _dragOffset!.dx - cellSize / 2,
            top: _dragOffset!.dy - cellSize / 2,
            width: cellSize,
            height: cellSize,
            child: PieceWidget(
              piece: piece,
              size: cellSize,
              isDragging: true,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _handleTapDown(TapDownDetails details) {
    if (_gameState.status != GameStatus.playing) return;

    final cellSize = MediaQuery.of(context).size.width / 8;
    final col = (details.localPosition.dx / cellSize).floor();
    final row = (details.localPosition.dy / cellSize).floor();
    final position = '${String.fromCharCode(97 + col)}${8 - row}';

    final piece = _gameState.board[row][col];

    if (piece != null && piece.color == _gameState.currentPlayer) {
      setState(() {
        _gameState = _gameState.copyWith(
          selectedSquare: position,
          validMoves: _getValidMovesForPosition(row, col),
        );
      });
    } else if (_gameState.selectedSquare != null &&
        _gameState.validMoves.contains(position)) {
      _movePiece(_gameState.selectedSquare!, position);
    } else {
      setState(() {
        _gameState = _gameState.copyWith(
          selectedSquare: null,
          validMoves: [],
        );
      });
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (_gameState.status != GameStatus.playing) return;

    final cellSize = MediaQuery.of(context).size.width / 8;
    final col = (details.localPosition.dx / cellSize).floor();
    final row = (details.localPosition.dy / cellSize).floor();
    final position = '${String.fromCharCode(97 + col)}${8 - row}';

    final piece = _gameState.board[row][col];

    if (piece != null && piece.color == _gameState.currentPlayer) {
      setState(() {
        _draggedPiecePosition = position;
        _dragOffset = details.localPosition;
        _gameState = _gameState.copyWith(
          selectedSquare: position,
          validMoves: _getValidMovesForPosition(row, col),
        );
      });
    }
  }
  void _showGameOverDialog(PieceColor? winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String message;
        if (winner == null) {
          message = 'Stalemate! It\'s a draw.';
        } else if (winner == PieceColor.white) {
          message = 'White wins!';
        } else {
          message = 'Black wins!';
        }

        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_draggedPiecePosition != null) {
      setState(() {
        _dragOffset = details.localPosition;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_draggedPiecePosition == null || _gameState.status != GameStatus.playing) {
      setState(() {
        _draggedPiecePosition = null;
        _dragOffset = null;
      });
      return;
    }

    final cellSize = MediaQuery.of(context).size.width / 8;
    final col = (_dragOffset!.dx / cellSize).floor();
    final row = (_dragOffset!.dy / cellSize).floor();
    final position = '${String.fromCharCode(97 + col)}${8 - row}';

    if (_gameState.validMoves.contains(position)) {
      _movePiece(_draggedPiecePosition!, position);
    }

    setState(() {
      _draggedPiecePosition = null;
      _dragOffset = null;
    });
  }

  List<String> _getValidMovesForPosition(int row, int col) {
    final moves = ChessRules.getValidMovesForPiece(_gameState, row, col);
    return moves.map((move) {
      return '${String.fromCharCode(97 + move.endCol)}${8 - move.endRow}';
    }).toList();
  }

  Future<void> _movePiece(String from, String to) async {
    final fromCol = from.codeUnitAt(0) - 97;
    final fromRow = 8 - int.parse(from.substring(1));
    final toCol = to.codeUnitAt(0) - 97;
    final toRow = 8 - int.parse(to.substring(1));

    final piece = _gameState.board[fromRow][fromCol];
    if (piece == null) return;

    Move move;

    if (piece.type == PieceType.pawn && (toRow == 0 || toRow == 7)) {
      final promotionType = await showDialog<PieceType>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PromotionDialog(
          color: piece.color,
          onSelected: (type) => type,
        ),
      ) ?? PieceType.queen;

      move = Move(
        startRow: fromRow,
        startCol: fromCol,
        endRow: toRow,
        endCol: toCol,
        promotion: promotionType,
      );
    } else {
      move = Move(
        startRow: fromRow,
        startCol: fromCol,
        endRow: toRow,
        endCol: toCol,
      );
    }

    final newState = ChessRules.makeMove(_gameState, move);

    // First update the state
    setState(() {
      _gameState = newState;
    });

    if (widget.gameState.isOnline) {
      await _firebaseService.updateGameState(widget.gameState.gameId!, _gameState);
    }

    // Check for game over conditions after state update
    if (ChessRules.isCheckmate(newState)) {
      // The player who just moved won (currentPlayer is now the opponent)
      _showGameOverDialog(newState.currentPlayer == PieceColor.white
          ? PieceColor.black : PieceColor.white);
    } else if (ChessRules.isStalemate(newState)) {
      _showGameOverDialog(null); // Draw
    } else if (widget.mode == GameMode.vsComputer &&
        newState.currentPlayer == PieceColor.black) {
      _makeComputerMove();
    }
  }
  void _makeComputerMove() {
    if (_gameState.status != GameStatus.playing) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _gameState.status != GameStatus.playing) return;

      final move = ChessAI.getBestMove(_gameState);
      final newState = ChessRules.makeMove(_gameState, move);

      setState(() {
        _gameState = newState;
      });

      if (widget.gameState.isOnline) {
        _firebaseService.updateGameState(widget.gameState.gameId!, _gameState);
      }

      // Check for game over conditions after computer move
      if (ChessRules.isCheckmate(newState)) {
        // Computer wins (currentPlayer is now white)
        _showGameOverDialog(PieceColor.black);
      } else if (ChessRules.isStalemate(newState)) {
        _showGameOverDialog(null); // Draw
      }
    });
  }


  void _resetGame() {
    setState(() {
      _gameState = GameState(
        board: _initializeBoard(),
        mode: widget.mode,
        isOnline: widget.gameState.isOnline,
        gameId: widget.gameState.gameId,
      );
    });

    if (widget.mode == GameMode.vsComputer &&
        _gameState.currentPlayer == PieceColor.black) {
      _makeComputerMove();
    }
  }
}