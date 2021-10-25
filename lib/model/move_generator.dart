import 'piece.dart';
import 'board.dart';

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
  Move? makeMove(Coord from, int toI, int toJ, { bool forCapture = false }) {
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
      } else if (pTo.isDark != get(from.i, from.j).isDark) {
        return Move.capture(from, Coord(toI, toJ));
      } else {
        return null;
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
        ret = pawnMoves(i, j, p.isLight);
      }
    }
    return ret;
  }

  // Moves for pawns
  List<Move> pawnMoves(int i, int j, bool isLight) {
    List<Move> ret = <Move>[];
    Coord from = Coord(i, j);
    int direction = isLight ? -1 : 1;
    // 1 square forward move
    ret.appendMove(makeMove(from, i+direction, j));
    // 2 square forward move
    if ((isLight && i == 6) || (!isLight && i == 1)) {
      ret.appendMove(makeMove(from, i+direction+direction, j));
    }
    // Capture left
    ret.appendMove(makeMove(from, i+direction, j-1, forCapture: true));
    // Capture right
    ret.appendMove(makeMove(from, i+direction, j+1, forCapture: true));
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
    List<Move> ret = <Move>[];
    return ret;
  }
}