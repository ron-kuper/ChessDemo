enum Piece { empty, kl, ql, rl, bl, nl, pl, kd, qd, rd, bd, nd, pd }

enum PieceColor { light, dark }

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
  PieceColor get color => isDark ? PieceColor.dark : PieceColor.light;
  bool get isEmpty => this == Piece.empty;
}
