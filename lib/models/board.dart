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
  List<List<Piece>> _squares = List.generate(8, (i) => List.generate(8, (j) => Piece.empty, growable: false), growable: false);

  // Keep track if we can castle or have already castled
  bool _lCastled = false;
  bool _dCastled = false;
  bool _lkMoved = false;
  bool _dkMoved = false;

  BoardModel() {
    reset();
  }

  void reset() {
    _squares = List.generate(8, (i) => List.generate(8, (j) => Piece.empty, growable: false), growable: false);
    _squares[7] = <Piece>[Piece.rl, Piece.nl, Piece.bl, Piece.ql, Piece.kl, Piece.bl, Piece.nl, Piece.rl];
    _squares[6] = List.generate(8, (i) => Piece.pl, growable: false);
    _squares[1] = List.generate(8, (i) => Piece.pd, growable: false);
    _squares[0] = <Piece>[Piece.rd, Piece.nd, Piece.bd, Piece.qd, Piece.kd, Piece.bd, Piece.nd, Piece.rd];
    notifyListeners();
  }

  BoardModel.from(BoardModel other) {
    _squares = other._squares.map((element) => List.from(element)).toList(growable: false).cast();
  }

  Piece get(int i, int j) {
    return _squares[i][j];
  }

  bool move(int fromI, int fromJ, int toI, int toJ) {
    assert(Coord.isValid(fromI, fromJ));
    assert(Coord.isValid(toI, toJ));
    Piece p = _squares[fromI][fromJ];
    _squares[toI][toJ] = p;
    _squares[fromI][fromJ] = Piece.empty;
    if (p.isKing) {
      if (p.isLight) _lkMoved = true;
      if (p.isDark) _dkMoved = true;
    }
    notifyListeners();
    return true;
  }

  bool didKingMove(PieceColor color) => color == PieceColor.light ? _lkMoved : _dkMoved;
  bool didKingCastle(PieceColor color) => color == PieceColor.light ? _lCastled : _dCastled;

  void setCastled(PieceColor color) {
    if (color == PieceColor.light) {
      _lCastled = true;
    } else {
      _dCastled = true;
    }
  }
}
