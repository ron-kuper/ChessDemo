// Representation of boards and moves

import 'dart:math';
import 'piece.dart';
import 'move_generator.dart';

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

  bool hasAdjacentKing(int i, int j, PieceColor color) {
    for (int ii = max(i-1, 0); ii < min(i+2, 8); ii++) {
      for (int jj = max(j-1, 0); jj < min(j+2, 8); jj++) {
        if (ii != i || jj != j) {
          Piece p = get(ii, jj);
          if (p.color == color && p.isKing) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool hasThreat(int i, int j, PieceColor opponentColor) {
    // Generate all non-pawn moves from this square. If any of the generated moves
    // is a capture, then we can capture them which means they can capture us...
    if (rookMoves(i, j, asColor: opponentColor).containsCapture() ||
        bishopMoves(i, j, asColor: opponentColor).containsCapture() ||
        knightMoves(i, j, asColor: opponentColor).containsCapture()) {
      return true;
    }

    // Calculate pawn backwards from potential capturing square
    int direction = opponentColor == PieceColor.light ? -1 : 1;
    if (pawnCaptures(i-direction, j-1, opponentColor).containsCapture() ||
        pawnCaptures(i-direction, j+1, opponentColor).containsCapture()) {
      return true;
    }

    // Treat threat from king specially
    return hasAdjacentKing(i, j, opponentColor);
  }
}