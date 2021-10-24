enum Piece { empty, kl, ql, rl, bl, nl, pl, kd, qd, rd, bd, nd, pd }

class Board {
  var _squares = List.generate(8, (i) => List.generate(8, (j) => Piece.empty, growable: false), growable: false);

  Board() {
    _squares[7] = <Piece>[Piece.rl, Piece.nl, Piece.bl, Piece.ql, Piece.kl, Piece.bl, Piece.nl, Piece.rl];
    _squares[6] = List.generate(8, (i) => Piece.pl, growable: false);
    _squares[1] = List.generate(8, (i) => Piece.pd, growable: false);
    _squares[0] = <Piece>[Piece.rd, Piece.nd, Piece.bd, Piece.qd, Piece.kd, Piece.bd, Piece.nd, Piece.rd];
  }

  operator[](int i) => _squares[i];
}