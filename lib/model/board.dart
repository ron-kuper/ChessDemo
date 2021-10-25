// Representation of boards and moves

import 'piece.dart';

class Coord {
  int i, j;
  Coord(this.i, this.j);
  static bool isValid(i, j) => i >= 0 && i < 8 && j >= 0 && j < 8;
  bool equals(Coord that) => that.i == i && that.j == j;
}

class Board {
  List<List<Piece>> _squares = List.generate(8, (i) => List.generate(8, (j) => Piece.empty, growable: false), growable: false);
  bool _lCastled = false;
  bool _dCastled = false;

  Board() {
    _squares[7] = <Piece>[Piece.rl, Piece.nl, Piece.bl, Piece.ql, Piece.kl, Piece.bl, Piece.nl, Piece.rl];
    _squares[6] = List.generate(8, (i) => Piece.pl, growable: false);
    _squares[1] = List.generate(8, (i) => Piece.pd, growable: false);
    _squares[0] = <Piece>[Piece.rd, Piece.nd, Piece.bd, Piece.qd, Piece.kd, Piece.bd, Piece.nd, Piece.rd];
  }

  Board.from(Board other) {
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
    return true;
  }
}