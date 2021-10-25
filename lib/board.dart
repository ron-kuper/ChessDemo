// Representation of pieces, boards and moves

enum Piece { empty, kl, ql, rl, bl, nl, pl, kd, qd, rd, bd, nd, pd }

extension PieceSvg on Piece {
  String get svgImage => 'assets/images/Chess_' + toString().substring(6) + 't45.svg';
}

extension PiecePredicates on Piece {
  bool get isKing => this == Piece.kl || this == Piece.kd;
  bool get isQueen => this == Piece.ql || this == Piece.qd;
  bool get isRook => this == Piece.rl || this == Piece.rd;
  bool get isBishop => this == Piece.bl || this == Piece.bd;
  bool get isKnight => this == Piece.nl || this == Piece.nd;
  bool get isPawn => this == Piece.pl || this == Piece.pd;
  bool get isLight => index >= Piece.kl.index && index <= Piece.pl.index;
  bool get isDark => index >= Piece.kd.index && index <= Piece.pd.index;
  bool get isEmpty => this == Piece.empty;
}

class Coord {
  int i, j;
  Coord(this.i, this.j);
  static bool isValid(i, j) => i >= 0 && i < 8 && j >= 0 && j < 8;
  bool equals(Coord that) => that.i == i && that.j == j;
}

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

extension MoveListPredicates on List<Move> {
  bool containsToSquare(Coord c) => any( (m) => m.to.equals(c) );
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

  List<Move> validMoves(int i, int j) {
    List<Move> ret = <Move>[];
    Coord from = Coord(i, j);
    Piece p = get(i, j);
    if (!p.isEmpty) {
      if (p.isKing) {
        return kingValidMoves(i, j);
      } else if (p.isQueen) {

      } else if (p.isBishop) {

      } else if (p.isKnight) {

      } else if (p.isRook) {

      } else if (p.isPawn) {
        int di = p.isLight ? -1 : 1;
        // 1 square forward move
        if (Coord.isValid(i+di, j) && get(i+di, j).isEmpty) {
          ret.add(Move.move(from, Coord(i+di, j)));
        }
        // 2 square forward move
        if ((p.isLight && i == 6) || (p.isDark && i == 1)) {
          if (Coord.isValid(i+di+di, j) && get(i+di+di, j).isEmpty) {
            ret.add(Move.move(from, Coord(i+di+di, j)));
          }
        }
        // Capture left
        if (Coord.isValid(i+di, j-1) && !get(i+di, j-1).isEmpty && get(i+di, j-1).isDark != p.isDark) {
          ret.add(Move.capture(from, Coord(i+di, j-1)));
        }
        // Capture right
        if (Coord.isValid(i+di, j+1) && !get(i+di, j+1).isEmpty && get(i+di, j+1).isDark != p.isDark) {
          ret.add(Move.capture(from, Coord(i+di, j+1)));
        }
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