import 'package:chess_demo/models/piece.dart';
import 'package:chess_demo/models/board.dart';

extension ThreatChecker on BoardModel {
  bool hasThreat(int i, int j, PieceColor opponentColor) {
    if (hasRankFileThreat(i, j, opponentColor)) {
      return true;
    }
    if (hasDiagonalThreat(i, j, opponentColor)) {
      return true;
    }
    if (hasKnightThreat(i, j, opponentColor)) {
      return true;
    }
    if (hasKingThreat(i, j, opponentColor)) {
      return true;
    }
    if (hasPawnThreat(i, j, opponentColor)) {
      return true;
    }
    return false;
  }

  // Check if the piece at (i,j) is a friend or a foe.
  // Throws 'foe' if foe, so allow threat checker to early out.
  // Otherwise returns true if the square is empty, false if occupied by a friendly.
  bool friendOrFoe(int i, int j, PieceColor opponentColor, bool Function(Piece) predicate) {
    if (!Coord.isValid(i, j)) {
      return true;
    } else {
      Piece p = get(i, j);
      if (p.color == opponentColor && predicate(p)) {
        throw 'foe';
      } else {
        return p.isEmpty;
      }
    }
  }

  bool rankFileFriendOrFoe(int i, int j, PieceColor opponentColor) {
    return friendOrFoe(i, j, opponentColor, (p) => p.isQueen || p.isRook);
  }

  bool hasRankFileThreat(int i, int j, PieceColor opponentColor) {
    bool up = true, dn = true, lt = true, rt = true;
    try {
      for (int scan = 1; scan < 7 && (up || dn || lt || rt); scan++) {
        if (up) up = rankFileFriendOrFoe(i-scan, j, opponentColor);
        if (dn) dn = rankFileFriendOrFoe(i+scan, j, opponentColor);
        if (lt) lt = rankFileFriendOrFoe(i, j-scan, opponentColor);
        if (rt) rt = rankFileFriendOrFoe(i, j-scan, opponentColor);
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  bool diagonalFriendOrFoe(int i, int j, PieceColor opponentColor) {
    return friendOrFoe(i, j, opponentColor, (p) => p.isQueen || p.isBishop);
  }

  bool hasDiagonalThreat(int i, int j, PieceColor opponentColor) {
    bool ne = true, se = true, nw = true, sw = true;
    try {
      for (int scan = 1; scan < 7 && (ne || se || nw || sw); scan++) {
        if (ne) ne = diagonalFriendOrFoe(i+scan, j+scan, opponentColor);
        if (se) se = diagonalFriendOrFoe(i+scan, j-scan, opponentColor);
        if (nw) nw = diagonalFriendOrFoe(i-scan, j+scan, opponentColor);
        if (sw) sw = diagonalFriendOrFoe(i-scan, j-scan, opponentColor);
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  bool knightFriendOrFoe(int i, int j, PieceColor opponentColor) {
    return friendOrFoe(i, j, opponentColor, (p) => p.isKnight);
  }

  bool hasKnightThreat(int i, int j, PieceColor opponentColor) {
    try {
      for (int dx = -2; dx <= 2; dx += 4) {
        for (int dy = -1; dy <= 1; dy += 2) {
          if (!knightFriendOrFoe(i+dx, j+dy, opponentColor)) {
            break;
          }
          if (!knightFriendOrFoe(i+dy, j+dx, opponentColor)) {
            break;
          }
        }
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  bool kingFriendOrFoe(int i, int j, PieceColor opponentColor) {
    return friendOrFoe(i, j, opponentColor, (p) => p.isKing);
  }

  bool hasKingThreat(int i, int j, PieceColor opponentColor) {
    try {
      for (int ii = i-1; ii < i+2; ii++) {
        for (int jj = j-1; jj < j+2; jj++) {
          if (ii != i || jj != j) {
            if (!kingFriendOrFoe(ii, jj, opponentColor)) {
              break;
            }
          }
        }
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  bool pawnFriendOrFoe(int i, int j, PieceColor opponentColor) {
    return friendOrFoe(i, j, opponentColor, (p) => p.isPawn);
  }

  bool hasPawnThreat(int i, int j, PieceColor opponentColor) {
    // Determine which way enemy pawns are moving
    int direction = opponentColor == PieceColor.light ? 1 : -1;
    try {
      pawnFriendOrFoe(i+direction, j-1, opponentColor);
      pawnFriendOrFoe(i+direction, j+1, opponentColor);
      return false;
    } catch (e) {
      return true;
    }
  }
}