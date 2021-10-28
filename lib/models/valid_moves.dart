import 'package:flutter/foundation.dart';
import 'package:chess_demo/models/piece.dart';
import 'package:chess_demo/models/move.dart';
import 'package:chess_demo/models/board.dart';

class ValidMovesModel extends ChangeNotifier {
  List<Move>? _moveList;
  final BoardModel _board;

  ValidMovesModel(this._board);

  List<Move>? get moveList => _moveList;

  List<Move>? calculateValidMoves(int i, int j) {
    Piece? pieceTap = _board.get(i, j);
    if (pieceTap != null) {
      _moveList = pieceTap.validMoves(Coord(i, j));
    } else {
      _moveList = null;
    }
    notifyListeners();
    return _moveList;
  }

  void reset() {
    notifyListeners();
    _moveList = null;
  }
}