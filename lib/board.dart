enum Piece { empty, kl, ql, rl, bl, nl, pl, kd, qd, rd, bd, nd, pd }

extension PieceSvg on Piece {
  String get svgImage {
    var pieceColor = this.toString().substring(6);
    return 'assets/images/Chess_' + pieceColor + 't45.svg';
  }
}

extension PiecePredicates on Piece {
  bool get isKing { return this == Piece.kl || this == Piece.kd; }
  bool get isQueen { return this == Piece.ql || this == Piece.qd; }
  bool get isRook { return this == Piece.rl || this == Piece.rd; }
  bool get isBishop { return this == Piece.bl || this == Piece.bd; }
  bool get isKnight { return this == Piece.nl || this == Piece.nd; }
  bool get isPawn { return this == Piece.pl || this == Piece.pd; }
  bool get isLight { return this.index >= Piece.kl.index && this.index <= Piece.pl.index; }
  bool get isDark { return this.index >= Piece.kd.index && this.index <= Piece.pd.index; }
  bool get isEmpty { return this == Piece.empty; }
}

class Coord {
  var i, j;
  Coord(this.i, this.j);
  static bool isValid(i, j) { return i >= 0 && i < 8 && j >= 0 && j < 8; }
}

class Move {
  Coord? from;
  Coord? to;
  bool? isCapture;
  bool? isCastle;

  Move.move(Coord from, Coord to) {
    this.from = from;
    this.to = to;
  }

  Move.capture(Coord from, Coord to) {
    this.from = from;
    this.to = to;
    this.isCapture = true;
  }

  Move.castle(Coord from, Coord to) {
    this.from = from;
    this.to = to;
    this.isCastle = true;
  }
}

class Board {
  var _squares = List.generate(8, (i) => List.generate(8, (j) => Piece.empty, growable: false), growable: false);
  bool _lCastled = false;
  bool _dCastled = false;

  Board() {
    _squares[7] = <Piece>[Piece.rl, Piece.nl, Piece.bl, Piece.ql, Piece.kl, Piece.bl, Piece.nl, Piece.rl];
    _squares[6] = List.generate(8, (i) => Piece.pl, growable: false);
    _squares[1] = List.generate(8, (i) => Piece.pd, growable: false);
    _squares[0] = <Piece>[Piece.rd, Piece.nd, Piece.bd, Piece.qd, Piece.kd, Piece.bd, Piece.nd, Piece.rd];
  }

  Piece get(int i, int j) {
    return _squares[i][j];
  }

  List<Move> validMoves(int i, int j) {
    List<Move> valids = <Move>[];
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
        if (Coord.isValid(i+di, j) && get(i+di, j).isEmpty) {
          valids.add(Move.move(from, Coord(i+di, j)));
        }
        if ((p.isLight && i == 6) || (p.isDark && i == 1)) {
          if (Coord.isValid(i+di+di, j) && get(i+di+di, j).isEmpty) {
            valids.add(Move.move(from, Coord(i+di+di, j)));
          }
        }
      }
    }
    print('Valid moves: ' + valids.toString());
    return valids;
  }

  // Kings can't move into check, so this one is extra special...
  List<Move> kingValidMoves(int i, int j) {
    List<Move> valids = <Move>[];
    return valids;
  }
}