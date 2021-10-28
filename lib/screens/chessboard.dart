import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess_demo/models/piece.dart';
import 'package:chess_demo/models/board.dart';
import 'package:chess_demo/models/move.dart';
import 'package:chess_demo/models/valid_moves.dart';

class Chessboard extends StatefulWidget {
  const Chessboard({Key? key}) : super(key: key);

  @override
  _ChessboardState createState() => _ChessboardState();
}

class _ChessboardState extends State<Chessboard> {
  int? _iTap, _jTap;

  @override
  Widget build(BuildContext context) {
    var squares = <GestureDetector>[];
    var light = const Color(0xFFEEEDD3);
    var dark = const Color(0xFF7C9B5F);
    bool isLight = true;

    BoardModel board = context.watch<BoardModel>();
    ValidMovesModel validMoves = context.watch<ValidMovesModel>();
    List<Move>? validMoveList = validMoves.moveList;
    for (int i = 0; i < 8; i++) {
      var isSqLight = isLight;
      for (int j = 0; j < 8; j++) {
        Coord c = Coord(i, j);
        Piece? p = board.get(i, j);

        // Get the image for the piece if the square is occupied
        SvgPicture? image;
        if (p != null) {
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
        Border? border;
        if (validMoveList != null && validMoveList.containsToSquare(c)) {
          border = Border.all(color: const Color.fromRGBO(0, 0, 0, 0.2), width: 16);
        }
        var square = GestureDetector(
            child: Container(
                margin: const EdgeInsets.all(0),
                padding: padding,
                decoration: BoxDecoration(
                  color: color,
                  border: border
                ),
                child: image),
            onTap: () {
              setState(() {
                if (_iTap == i && _jTap == j) {
                  validMoves.reset();
                } else if (validMoveList != null && validMoveList.isNotEmpty) {
                  Coord c = Coord(i, j);
                  Move? m = validMoveList.getMoveToSquare(c);
                  if (m != null) {
                    board.performMove(m);
                    validMoves.reset();
                  } else {
                    validMoves.calculateValidMoves(i, j);
                  }
                } else {
                  validMoves.calculateValidMoves(i, j);
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
