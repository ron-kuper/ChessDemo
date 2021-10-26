import 'dart:math';
import 'piece.dart';
import 'board.dart';
import 'threat_checker.dart';

class Move {
  Coord from;
  Coord to;
  bool isCapture = false;
  bool isCastle = false;

  bool equals(Move that) =>
      that.from.equals(from) &&
          that.to.equals(to) &&
          that.isCapture == isCapture &&
          that.isCastle == isCastle;

  Move.move(this.from, this.to);

  Move.capture(this.from, this.to) {
    isCapture = true;
  }

  Move.castle(this.from, this.to) {
    isCastle = true;
  }
}

extension MoveList on List<Move> {
  bool containsToSquare(Coord c) => any( (m) => m.to.equals(c) );
  bool containsCapture() => any( (m) => m.isCapture );

  Move? getMoveToSquare(Coord c) {
    Move? m;
    try {
      m = firstWhere((m) => m.to.equals(c));
    } catch (e) {
      m = null;
    }
    return m;
  }

  // Adds another move to the list. Returns false if this is the last allowable
  // move in a series of possibilities (due to capture or castle)
  bool appendMove(Move? m) {
    if (m != null) {
      add(m);
      return !m.isCastle && !m.isCapture;
    } else {
      return false;
    }
  }
}

extension MoveGenerator on Board {
  // Returns a move, capture or null depending on what's in the target square
  Move? makeMove(Coord from,
                 int toI, int toJ,
                 { bool forCapture = false }) {
    if (!Coord.isValid(toI, toJ)) {
      return null;
    } else {
      Piece pTo = get(toI, toJ);
      if (pTo.isEmpty) {
        if (!forCapture) {
          return Move.move(from, Coord(toI, toJ));
        } else {
          return null;
        }
      } else {
        PieceColor toColor = pTo.color;
        PieceColor fromColor = get(from.i, from.j).color;
        if (fromColor != toColor) {
          return Move.capture(from, Coord(toI, toJ));
        } else {
          return null;
        }
      }
    }
  }

  List<Move> validMoves(int i, int j) {
    List<Move> ret = <Move>[];
    Piece p = get(i, j);
    if (!p.isEmpty) {
      if (p.isKing) {
        ret = kingValidMoves(i, j);
      } else if (p.isQueen) {
        ret = rookMoves(i, j);
        ret.addAll(bishopMoves(i, j));
      } else if (p.isBishop) {
        ret = bishopMoves(i, j);
      } else if (p.isKnight) {
        ret = knightMoves(i, j);
      } else if (p.isRook) {
        ret = rookMoves(i, j);
      } else if (p.isPawn) {
        ret = pawnMoves(i, j, p.color);
        ret.addAll(pawnCaptures(i, j, p.color));
      }
    }
    return ret;
  }

  // Moves for pawns
  List<Move> pawnMoves(int i, int j, PieceColor asColor) {
    List<Move> ret = <Move>[];
    Coord from = Coord(i, j);
    bool isLight = (asColor == PieceColor.light);
    int direction = asColor == PieceColor.light ? -1 : 1;
    // 1 square forward move
    ret.appendMove(makeMove(from, i + direction, j));
    // 2 square forward move
    if ((isLight && i == 6) || (!isLight && i == 1)) {
      ret.appendMove(makeMove(from, i + direction + direction, j));
    }
    return ret;
  }

  List<Move> pawnCaptures(int i, int j, PieceColor asColor) {
    List<Move> ret = <Move>[];
    if (Coord.isValid(i, j)) {
      Coord from = Coord(i, j);
      int direction = asColor == PieceColor.light ? -1 : 1;
      // Capture left
      ret.appendMove(makeMove(from, i + direction, j - 1, forCapture: true));
      // Capture right
      ret.appendMove(makeMove(from, i + direction, j + 1, forCapture: true));
    }
    return ret;
  }

  // Moves for rooks (and queens)
  List<Move> rookMoves(int i, int j) {
    List<Move> ret = <Move>[];
    Coord from = Coord(i, j);
    // Scan right
    for (int jj = j+1; jj < 8; jj++) {
      if (!ret.appendMove(makeMove(from, i, jj))) {
        break;
      }
    }
    // Scan left
    for (int jj = j-1; jj >= 0; jj--) {
      if (!ret.appendMove(makeMove(from, i, jj))) {
        break;
      }
    }
    // Scan down
    for (int ii = i+1; ii < 8; ii++) {
      if (!ret.appendMove(makeMove(from, ii, j))) {
        break;
      }
    }
    // Scan up
    for (int ii = i-1; ii >= 0; ii--) {
      if (!ret.appendMove(makeMove(from, ii, j))) {
        break;
      }
    }
    return ret;
  }

  // Moves for bishops (and queens)
  List<Move> bishopMoves(int i, int j) {
    List<Move> ret = <Move>[];
    Coord from = Coord(i, j);
    // Scan 4 diagonals
    bool ne = true, se = true, nw = true, sw = true;
    for (int scan = 1; scan < 7; scan++) {
      if (ne) ne = ret.appendMove(makeMove(from, i+scan, j+scan));
      if (se) se = ret.appendMove(makeMove(from, i+scan, j-scan));
      if (nw) nw = ret.appendMove(makeMove(from, i-scan, j+scan));
      if (sw) sw = ret.appendMove(makeMove(from, i-scan, j-scan));
      if (!ne && !se && !nw && !sw) {
        break;
      }
    }
    return ret;
  }

  // Moves for knights
  List<Move> knightMoves(int i, int j) {
    List<Move> ret = <Move>[];
    Coord from = Coord(i, j);
    for (int dx = -2; dx <= 2; dx += 4) {
      for (int dy = -1; dy <= 1; dy += 2) {
        ret.appendMove(makeMove(from, i+dx, j+dy));
        ret.appendMove(makeMove(from, i+dy, j+dx));
      }
    }
    return ret;
  }

  // Kings can't move into check, so this one is extra special...
  List<Move> kingValidMoves(int i, int j) {
    Coord from = Coord(i, j);
    PieceColor myColor = get(i, j).color;
    PieceColor opponentColor = (myColor == PieceColor.light) ? PieceColor.dark : PieceColor.light;
    List<Move> ret = <Move>[];

    // Start by checking regular moves
    for (int ii = max(i-1, 0); ii < min(i+2, 8); ii++) {
      for (int jj = max(j-1, 0); jj < min(j+2, 8); jj++) {
        if (ii != i || jj != j) {
          if (!hasThreat(ii, jj, opponentColor)) {
            ret.appendMove(makeMove(from, ii, jj));
          }
        }
      }
    }

    // Check for castles
    if (!didKingMove(myColor) && !didKingCastle(myColor)) {

    }

    return ret;
  }
}