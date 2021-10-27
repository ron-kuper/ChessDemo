// Representation of boards and moves

import 'package:flutter/foundation.dart';
import 'package:chess_demo/models/piece.dart';

class Coord {
  int i, j;
  Coord(this.i, this.j);
  static bool isValid(i, j) => i >= 0 && i < 8 && j >= 0 && j < 8;
  bool equals(Coord that) => that.i == i && that.j == j;
}

class BoardModel extends ChangeNotifier {
  List<List<Piece?>> _squares = List.generate(8, (i) => List.generate(8, (j) => null, growable: false), growable: false);

  // Keep track if we can castle or have already castled
  bool _lCastled = false;
  bool _dCastled = false;

  BoardModel() {
    reset();
  }

  void reset() {
    _squares = List.generate(8, (i) => List.generate(8, (j) => null, growable: false), growable: false);
    const PieceColor l = PieceColor.light;
    const PieceColor d = PieceColor.dark;
    _squares[7] = [Rook(this, l), Knight(this, l), Bishop(this, l), Queen(this, l), King(this, l), Bishop(this, l), Knight(this, l), Rook(this, l)];
    _squares[6] = List.generate(8, (i) => Pawn(this, l), growable: false);
    _squares[1] = List.generate(8, (i) => Pawn(this, d), growable: false);
    _squares[0] = [Rook(this, d), Knight(this, d), Bishop(this, d), Queen(this, d), King(this, d), Bishop(this, d), Knight(this, d), Rook(this, d)];
    notifyListeners();
  }

  BoardModel.from(BoardModel other) {
    _squares = other._squares.map((element) => List.from(element)).toList(growable: false).cast();
  }

  Piece? get(int i, int j) {
    return _squares[i][j];
  }

  bool move(int fromI, int fromJ, int toI, int toJ) {
    assert(Coord.isValid(fromI, fromJ));
    assert(Coord.isValid(toI, toJ));
    Piece? p = _squares[fromI][fromJ];
    assert(p != null);
    _squares[toI][toJ] = p;
    _squares[fromI][fromJ] = null;
    p!.moved = true;
    notifyListeners();
    return true;
  }

  bool didKingCastle(PieceColor color) => color == PieceColor.light ? _lCastled : _dCastled;

  void setCastled(PieceColor color) {
    if (color == PieceColor.light) {
      _lCastled = true;
    } else {
      _dCastled = true;
    }
  }
}
