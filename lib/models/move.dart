import 'package:chess_demo/models/board.dart';
import 'package:chess_demo/models/piece.dart';

enum MoveType { move, castle, capture, enPassant }
enum KingThreat { none, check, checkmate }

class Move {
  Piece piece;
  Coord from;
  Coord to;
  MoveType moveType = MoveType.move;
  KingThreat kingThreat = KingThreat.none;

  bool equals(Move that) =>
      that.from.equals(from) && that.to.equals(to) && that.moveType == moveType;

  Move(this.piece, this.from, this.to, { this.moveType = MoveType.move });

  bool get isMove => moveType == MoveType.move;

  bool get isCapture => moveType == MoveType.capture;

  bool get isCastle => moveType == MoveType.castle;

  bool get isEnPassant => moveType == MoveType.enPassant;

  @override
  String toString() {
    return toAlgebraic();
  }

  String toAlgebraic() {
    String ret = '';
    String p = piece.name();
    if (piece is Pawn && (isCapture || isEnPassant)) {
      p = 'abcdefgh'[from.j];
    }
    String col = 'abcdefgh'[to.i];
    String row = (8 - to.j).toString();
    if (isCapture) {
      ret = p + 'x' + col + row;
    } else if (isCastle) {
      if (to.j == 2) {
        ret = 'O-O-O';
      } else {
        ret = 'O-O';
      }
    } else {
      ret = p + col + row;
    }
    if (kingThreat == KingThreat.check) {
      ret = ret + '+';
    } else if (kingThreat == KingThreat.checkmate) {
      ret = ret + '#';
    }
    return ret;
  }

  String toUCI () => 'abcdefgh'[from.j] + (8-from.i).toString() + 'abcdefgh'[to.j] + (8-to.i).toString();
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
