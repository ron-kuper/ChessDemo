import 'package:chess_demo/models/board.dart';

enum MoveType { move, castle, capture, enPassant }

class Move {
  Coord from;
  Coord to;
  MoveType moveType = MoveType.move;

  bool equals(Move that) =>
      that.from.equals(from) && that.to.equals(to) && that.moveType == moveType;

  Move(this.from, this.to, { this.moveType = MoveType.move });

  bool get isMove => moveType == MoveType.move;
  bool get isCapture => moveType == MoveType.capture;
  bool get isCastle => moveType == MoveType.castle;
  bool get isEnPassant => moveType == MoveType.enPassant;
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
