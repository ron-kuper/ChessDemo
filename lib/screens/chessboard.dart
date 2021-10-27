import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess_demo/models/piece.dart';
import 'package:chess_demo/models/board.dart';
import 'package:chess_demo/models/move_generator.dart';

class Chessboard extends StatefulWidget {
  const Chessboard({Key? key}) : super(key: key);

  @override
  _ChessboardState createState() => _ChessboardState();
}

class _ChessboardState extends State<Chessboard> {
  int? _iTap, _jTap;
  Piece? _pieceTap;
  List<Move>? _validMoves;

  void setTap(BoardModel board, int i, int j) {
    _iTap = i;
    _jTap = j;
    _pieceTap = board.get(i, j);
    _validMoves = board.validMoves(i, j);
  }

  void resetTap() {
    _iTap = _jTap = null;
    _pieceTap = null;
    _validMoves = null;
  }

  @override
  Widget build(BuildContext context) {
    var squares = <GestureDetector>[];
    var light = const Color(0xFFEEEDD3);
    var dark = const Color(0xFF7C9B5F);
    bool isLight = true;

    BoardModel board = context.watch<BoardModel>();
    for (int i = 0; i < 8; i++) {
      var isSqLight = isLight;
      for (int j = 0; j < 8; j++) {
        Coord c = Coord(i, j);
        Piece p = board.get(i, j);

        // Get the image for the piece if the square is occupied
        SvgPicture? image;
        if (p != Piece.empty) {
          image = SvgPicture.asset(p.svgImage);
        }

        // Determine the background color for the square, highlighting
        // the square that was tapped if any
        Color color;
        if (i == _iTap && j == _jTap) {
          color = isSqLight ? light : dark;
          color = color.withOpacity(0.5); // highlight;
        } else {
          color = isSqLight ? light : dark;
        }

        EdgeInsetsGeometry? padding;
        if (_validMoves != null && _validMoves!.containsToSquare(c)) {
          image = SvgPicture.asset(_pieceTap!.svgImage);
          padding = const EdgeInsets.all(10);
          color = color.withOpacity(0.5);
        }

        var square = GestureDetector(
            child: Container(
                margin: const EdgeInsets.all(0),
                padding: padding,
                child: image,
                color: color),
            onTap: () {
              setState(() {
                if (_iTap == i && _jTap == j) {
                  resetTap();
                } else if (_validMoves != null && _validMoves!.isNotEmpty) {
                  Coord c = Coord(i, j);
                  Move? m = _validMoves!.getMoveToSquare(c);
                  if (m != null) {
                    board.move(m.from.i, m.from.j, m.to.i, m.to.j);
                    resetTap();
                  } else {
                    setTap(board, i, j);
                  }
                } else {
                  setTap(board, i, j);
                }
              });
            });
        isSqLight = !isSqLight;
        squares.add(square);
      }
      isLight = !isLight;
    }

    return Center(
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisCount: 8,
          children: squares
        )
    );
  }
}
