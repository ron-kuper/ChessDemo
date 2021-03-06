import 'package:chess_demo/models/board.dart';
import 'package:chess_demo/models/threat_checker.dart';
import 'package:chess_demo/models/move.dart';
import 'package:flutter/material.dart';

enum PieceColor { white, black }

abstract class Piece {
  final BoardModel _board;
  final PieceColor _color;
  final String _svgImageCode;
  final GlobalKey _key = GlobalKey();
  bool moved = false;

  Piece(this._board, this._color, this._svgImageCode);

  Key get key => _key;

  PieceColor get color => _color;
  bool get isWhite => _color == PieceColor.white;
  bool get isBlack => _color == PieceColor.black;

  String get svgImage => 'assets/images/Chess_' + _svgImageCode + (isWhite ? 'l' : 'd') + 't45.svg';

  // Returns a move, capture or null depending on what's in the target square
  Move? makeMove(Coord from, int deltaI, int deltaJ, { MoveType moveType = MoveType.move }) {
    Move? ret;
    int toI = from.i + deltaI;
    int toJ = from.j + deltaJ;
    if (Coord.isValid(toI, toJ)) {
      Piece? pFrom = _board.get(from.i, from.j);
      assert( pFrom != null );
      Piece? pTo = _board.get(moveType == MoveType.enPassant ? from.i : toI, toJ);
      if (pTo == null) {
        if (moveType == MoveType.move || moveType == MoveType.castle) {
          ret = Move(pFrom!, from, Coord(toI, toJ), moveType: moveType);
        }
      } else {
        PieceColor toColor = pTo.color;
        PieceColor fromColor = _board.get(from.i, from.j)!.color;
        if (fromColor != toColor) {
          ret = Move(pFrom!, from, Coord(toI, toJ), moveType: MoveType.capture);
        }
      }
    }

    return ret;
  }

  List<Move> validMoves(Coord from);
  String name();
}

class Pawn extends Piece {
  Pawn(BoardModel board, PieceColor color) : super(board, color, 'p');

  @override
  String name() => '';

  @override
  List<Move> validMoves(Coord from) {
    List<Move> ret = <Move>[];
    int direction = isWhite ? -1 : 1;
    // 1 square forward move
    ret.appendMove(makeMove(from, direction, 0));
    // 2 square forward move
    if ((isWhite && from.i == 6) || (!isWhite && from.i == 1)) {
      ret.appendMove(makeMove(from, direction + direction, 0));
    }
    // Capture left
    ret.appendMove(makeMove(from, direction, -1, moveType: MoveType.capture));
    // Capture right
    ret.appendMove(makeMove(from, direction, 1, moveType: MoveType.capture));
    // En passant left
    if (Coord.isValid(from.i, from.j-1)) {
      Piece? p = _board.get(from.i, from.j-1);
      if (p is Pawn && _board.isEnPassantPawn(p)) {
        ret.appendMove(makeMove(from, direction, -1, moveType: MoveType.enPassant));
      }
    }
    // En passant right
    if (Coord.isValid(from.i, from.j+1)) {
      Piece? p = _board.get(from.i, from.j+1);
      if (p is Pawn && _board.isEnPassantPawn(p)) {
        ret.appendMove(makeMove(from, direction, 1, moveType: MoveType.enPassant));
      }
    }
    return ret;
  }
}

class Knight extends Piece {
  Knight(BoardModel board, PieceColor color) : super(board, color, 'n');

  @override
  String name() => 'N';

  @override
  List<Move> validMoves(Coord from) {
    List<Move> ret = <Move>[];
    for (int dx = -2; dx <= 2; dx += 4) {
      for (int dy = -1; dy <= 1; dy += 2) {
        ret.appendMove(makeMove(from, dx, dy));
        ret.appendMove(makeMove(from, dy, dx));
      }
    }
    return ret;
  }
}

class Bishop extends Piece {
  Bishop(BoardModel board, PieceColor color) : super(board, color, 'b');

  @override
  String name() => 'B';

  @override
  List<Move> validMoves(Coord from) {
    List<Move> ret = <Move>[];
    // Scan 4 diagonals
    bool ne = true, se = true, nw = true, sw = true;
    for (int scan = 1; scan < 7; scan++) {
      if (ne) ne = ret.appendMove(makeMove(from,  scan,  scan));
      if (se) se = ret.appendMove(makeMove(from,  scan, -scan));
      if (nw) nw = ret.appendMove(makeMove(from, -scan,  scan));
      if (sw) sw = ret.appendMove(makeMove(from, -scan, -scan));
      if (!ne && !se && !nw && !sw) {
        break;
      }
    }
    return ret;
  }
}

class Rook extends Piece {
  Rook(BoardModel board, PieceColor color) : super(board, color, 'r');

  @override
  String name() => 'R';

  @override
  List<Move> validMoves(Coord from) {
    List<Move> ret = <Move>[];
    // Scan 4 axes
    bool up = true, dn = true, lt = true, rt = true;
    for (int scan = 1; scan < 8; scan++) {
      if (up) up = ret.appendMove(makeMove(from, -scan,  0));
      if (dn) dn = ret.appendMove(makeMove(from,  scan,  0));
      if (lt) lt = ret.appendMove(makeMove(from,  0,    -scan));
      if (rt) rt = ret.appendMove(makeMove(from,  0,     scan));
      if (!up && !dn && !lt && !rt) {
        break;
      }
    }
    return ret;
  }
}

class Queen extends Piece {
  Queen(BoardModel board, PieceColor color) : super(board, color, 'q');

  @override
  String name() => 'Q';

  @override
  List<Move> validMoves(Coord from) {
    List<Move> ret = Rook(_board, color).validMoves(from);
    ret.addAll(Bishop(_board, color).validMoves(from));
    return ret;
  }
}

class King extends Piece {
  bool castled = false;

  King(BoardModel board, PieceColor color) : super(board, color, 'k');

  @override
  String name() => 'K';

  @override
  List<Move> validMoves(Coord from) {
    List<Move> ret = <Move>[];
    PieceColor opponentColor = (color == PieceColor.white) ? PieceColor.black : PieceColor.white;

    // Start by checking regular moves
    for (int ii = -1; ii < 2; ii++) {
      for (int jj = -1; jj < 2; jj++) {
        if (ii != 0 || jj != 0) {
          if (!_board.hasThreat(from.i+ii, from.j+jj, opponentColor)) {
            ret.appendMove(makeMove(from, ii, jj));
          }
        }
      }
    }

    // Check for castles - need empty squares to the rook, king and rook
    // can't have moved, not threats for king to castled square
    if (!moved && !castled) {
      // King side
      if (_board.get(from.i, 7) is Rook && !_board.get(from.i, 7)!.moved) {
        bool hasImpediment = false;
        for (int jj = 1; jj < 3 && !hasImpediment; jj++) {
          hasImpediment = _board.get(from.i, from.j+jj) != null || _board.hasThreat(from.i, from.j+jj, opponentColor);
        }
        if (!hasImpediment) {
          ret.appendMove(makeMove(from, 0, 2, moveType: MoveType.castle));
        }
      }
      // Queen side
      if (_board.get(from.i, 0) is Rook && !_board.get(from.i, 0)!.moved) {
        bool hasImpediment = false;
        for (int jj = -2; jj < 0 && !hasImpediment; jj++) {
          hasImpediment = _board.get(from.i, from.j+jj) != null || _board.hasThreat(from.i, from.j+jj, opponentColor);
        }
        if (!hasImpediment) {
          ret.appendMove(makeMove(from, 0, -2, moveType: MoveType.castle));
        }
      }
    }

    return ret;
  }
}
