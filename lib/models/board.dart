// Representation of boards and moves

import 'package:flutter/foundation.dart';
import 'package:chess_demo/models/piece.dart';
import 'package:chess_demo/models/move.dart';

class Coord {
  int i, j;
  Coord(this.i, this.j);
  static bool isValid(i, j) => i >= 0 && i < 8 && j >= 0 && j < 8;
  bool equals(Coord that) => that.i == i && that.j == j;
}

class BoardModel extends ChangeNotifier {
  List<List<Piece?>> _squares = List.generate(8, (i) => List.generate(8, (j) => null, growable: false), growable: false);

  // Keep track of which pawn are vulnerable to en passant next turn
  Pawn? _lightPawnEnPassant;
  Pawn? _darkPawnEnPassant;

  bool isEnPassantPawn(Pawn p) {
    return _darkPawnEnPassant == p || _lightPawnEnPassant == p;
  }

  BoardModel() {
    reset();
  }

  void reset() {
    _squares = List.generate(8, (i) => List.generate(8, (j) => null, growable: false), growable: false);
    const PieceColor l = PieceColor.light;
    const PieceColor d = PieceColor.dark;
    _squares[7] = [Rook(this, l),
      Knight(this, l),
      Bishop(this, l),
      Queen(this, l),
      King(this, l),
      Bishop(this, l),
      Knight(this, l),
      Rook(this, l)
    ];
    _squares[6] = List.generate(8, (i) => Pawn(this, l), growable: false);
    _squares[1] = List.generate(8, (i) => Pawn(this, d), growable: false);
    _squares[0] = [
      Rook(this, d),
      Knight(this, d),
      Bishop(this, d),
      Queen(this, d),
      King(this, d),
      Bishop(this, d),
      Knight(this, d),
      Rook(this, d)
    ];
    notifyListeners();
  }

  BoardModel.from(BoardModel other) {
    _squares = other._squares.map((element) => List.from(element)).toList(growable: false).cast();
  }

  Piece? get(int i, int j) {
    return _squares[i][j];
  }

  bool performMove(Move move) {
    Piece? p = _squares[move.from.i][move.from.j];
    assert(p != null);
    _squares[move.to.i][move.to.j] = p;
    _squares[move.from.i][move.from.j] = null;
    if (move.isEnPassant) {
      _squares[move.from.i][move.to.j] = null;
    } else if (move.isCastle) {
      if (move.to.j == 6) { // king side
        _squares[move.from.i][5] = _squares[move.from.i][7];
        _squares[move.from.i][7] = null;
      } else {
        _squares[move.from.i][3] = _squares[move.from.i][0];
        _squares[move.from.i][0] = null;
      }
      (p as King).castled = true;
    }
    p!.moved = true;

    // Once a piece has moved, en passant capture is no longer possible from
    // the last possible pawn move
    if (p.isLight) {
      _darkPawnEnPassant = null;
    } else {
      _lightPawnEnPassant = null;
    }

    // Flag pawns that can be captured en passant
    if (p is Pawn) {
      if (move.from.i - move.to.i == 2 || move.from.i - move.to.i == -2) {
        if (p.isLight) {
          _lightPawnEnPassant = p;
        } else {
          _darkPawnEnPassant = p;
        }
      }
    }

    notifyListeners();
    return true;
  }
}