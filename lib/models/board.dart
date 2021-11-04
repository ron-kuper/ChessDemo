// Representation of boards and moves

import 'package:flutter/foundation.dart';
import 'package:chess_demo/models/piece.dart';
import 'package:chess_demo/models/move.dart';
import 'package:chess_demo/models/threat_checker.dart';
import 'package:chess_demo/models/openings.dart';

class Coord {
  int i, j;
  Coord(this.i, this.j);
  static bool isValid(i, j) => i >= 0 && i < 8 && j >= 0 && j < 8;
  bool equals(Coord that) => that.i == i && that.j == j;
}

class BoardModel extends ChangeNotifier {
  List<List<Piece?>> _squares = List.generate(8, (i) => List.generate(8, (j) => null, growable: false), growable: false);
  List<Move> _moves = <Move>[];

  // Keep track of which pawn are vulnerable to en passant next turn
  Pawn? _whitePawnEnPassant;
  Pawn? _blackPawnEnPassant;
  bool isEnPassantPawn(Pawn p) =>_blackPawnEnPassant == p || _whitePawnEnPassant == p;

  // Keep track of whose move it is
  PieceColor _whoseMove = PieceColor.white;
  PieceColor get whoseMove => _whoseMove;

  // Keep track of each king's position so we don't have to find it to compute checks
  Coord whiteKingLoc = Coord(0, 4);
  Coord blackKingLoc = Coord(7, 4);

  BoardModel() {
    reset();
  }

  void reset() {
    _squares = List.generate(8, (i) => List.generate(8, (j) => null, growable: false), growable: false);
    const PieceColor w = PieceColor.white;
    const PieceColor b = PieceColor.black;
    _squares[7] = [Rook(this, w),
      Knight(this, w),
      Bishop(this, w),
      Queen(this, w),
      King(this, w),
      Bishop(this, w),
      Knight(this, w),
      Rook(this, w)
    ];
    _squares[6] = List.generate(8, (i) => Pawn(this, w), growable: false);
    _squares[1] = List.generate(8, (i) => Pawn(this, b), growable: false);
    _squares[0] = [
      Rook(this, b),
      Knight(this, b),
      Bishop(this, b),
      Queen(this, b),
      King(this, b),
      Bishop(this, b),
      Knight(this, b),
      Rook(this, b)
    ];
    _moves = <Move>[];
    _whoseMove = PieceColor.white;
    whiteKingLoc = Coord(7, 4);
    blackKingLoc = Coord(0, 4);
    notifyListeners();
  }

  BoardModel.from(BoardModel other) {
    _squares = other._squares.map((element) => List.from(element)).toList(growable: false).cast();
    _moves = other._moves.map((e) => e).toList();
    _whitePawnEnPassant = other._whitePawnEnPassant;
    _blackPawnEnPassant = other._blackPawnEnPassant;
    _whoseMove = other._whoseMove;
    whiteKingLoc = other.whiteKingLoc;
    blackKingLoc = other.blackKingLoc;
  }

  Piece? get(int i, int j) {
    return _squares[i][j];
  }

  bool performMove(Move move) {
    Piece? p = _squares[move.from.i][move.from.j];
    assert(p != null);
    assert(p!.color == whoseMove);
    _squares[move.to.i][move.to.j] = p;
    _squares[move.from.i][move.from.j] = null;
    if (move.isEnPassant) {
      _squares[move.from.i][move.to.j] = null;
    } else if (move.isCastle) {
      if (move.to.j == 6) { // king side
        _squares[move.from.i][5] = _squares[move.from.i][7];
        _squares[move.from.i][7] = null;
      } else {
        _squares[move.from.i][3] = _squares[move.from.i][0];
        _squares[move.from.i][0] = null;
      }
      (p as King).castled = true;
    }
    p!.moved = true;

    // Keep track of the king's position
    if (p is King) {
      if (p.isWhite) {
        whiteKingLoc = move.to;
      } else {
        blackKingLoc = move.to;
      }
    }

    // Once a piece has moved, en passant capture is no longer possible from
    // the last possible pawn move
    if (p.isWhite) {
      _blackPawnEnPassant = null;
    } else {
      _whitePawnEnPassant = null;
    }

    // Flag pawns that can be captured en passant
    if (p is Pawn) {
      if (move.from.i - move.to.i == 2 || move.from.i - move.to.i == -2) {
        if (p.isWhite) {
          _whitePawnEnPassant = p;
        } else {
          _blackPawnEnPassant = p;
        }
      }
    }

    // See if this move is check/checkmate
    PieceColor myColor = p.color;
    PieceColor opponentColor = p.isWhite ? PieceColor.black : PieceColor.white;
    Coord oppoKingLoc = opponentColor == PieceColor.black ? blackKingLoc : whiteKingLoc;
    if (hasThreat(oppoKingLoc.i, oppoKingLoc.j, myColor)) {
      // At least check... is it also mate?
      bool freeSquare = false;
      for (int ii = oppoKingLoc.i-1; ii < oppoKingLoc.i+2 && !freeSquare; ii++) {
        for (int jj = oppoKingLoc.j-1; jj < oppoKingLoc.j+2 && !freeSquare; jj++) {
          if ((ii != oppoKingLoc.i || jj != oppoKingLoc.j) && Coord.isValid(ii, jj) && get(ii, jj) == null) {
            if (!hasThreat(ii, jj, myColor)) {
              freeSquare = true;
            }
          }
        }
      }
      move.kingThreat = freeSquare ? KingThreat.check : KingThreat.checkmate;
    }

    _moves.add(move);

    // Other side's move
    _whoseMove = whoseMove == PieceColor.white ? PieceColor.black : PieceColor.white;

    debugPrint(moveListToUCI());

    String url = 'https://explorer.lichess.ovh/masters?play=' + moveListToUCI();
    Openings? openings;
    try {
      Future<Openings>? future = Openings.fetchOpenings(url);
      future!.then((o) {
        debugPrint('Got openings!');
        openings = o;
      }).catchError((e) {
        debugPrint('Future error: ' + e.toString());
      });
    } catch (e) {
      debugPrint('Fetch exception: ' + e.toString());
    }

    notifyListeners();
    return true;
  }

  String moveListToAlgebraic() {
    String ret = '';
    int moveNum = 1;
    for (int i = 0; i < _moves.length; i++) {
      if (i % 2 == 0) {
        ret = ret + moveNum.toString() + '. ';
      }
      ret = ret + _moves[i].toAlgebraic() + ' ';
      if (i % 2 == 1) {
        moveNum++;
      }
    }
    return ret;
  }

  String moveListToUCI() {
    String ret = '';
    int moveNum = 1;
    for (int i = 0; i < _moves.length; i++) {
      if (i > 0) {
        ret = ret + ',';
      }
      ret = ret + _moves[i].toUCI();
    }
    return ret;
  }
}