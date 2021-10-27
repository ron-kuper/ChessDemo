import 'package:chess_demo/models/board.dart';

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
