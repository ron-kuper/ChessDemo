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
    const double boardInset = 0;
    MediaQueryData mq = MediaQuery.of(context);
    double width = mq.size.width - boardInset*2;
    double height = mq.size.height - boardInset*2;
    double size = width > height ? height : width;

    // Find a agreeable row label width that can be an integer with integer square sizes
    double squareSize = ((size-12) / 8).floor().toDouble();
    double rowLabelWidth = size - squareSize * 8;
    double colLabelHeight = rowLabelWidth;

    var squares = <GestureDetector>[];
    var pieces = <AnimatedPositioned>[];
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
        if (p != null) {
          SvgPicture image = SvgPicture.asset(p.svgImage);
          var piece = AnimatedPositioned(
            key: p.key,
            width: squareSize,
            height: squareSize,
            top: i * squareSize,
            left: j * squareSize,
            child: IgnorePointer(ignoring: true, child: image),
            duration: const Duration(milliseconds: 250)
          );
          pieces.add(piece);
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

        Border? border;
        if (validMoveList != null && validMoveList.containsToSquare(c)) {
          border = Border.all(color: const Color.fromRGBO(0, 0, 0, 0.2), width: 16);
        }
        var square = GestureDetector(
            child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                    color: color,
                    border: border
                )),
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

    List<Widget> gridStack = <Widget>[
      GridView.count(
        primary: false,
        padding: const EdgeInsets.all(boardInset),
        crossAxisCount: 8,
        children: squares)
    ];

    gridStack.addAll(pieces);

    Center boardGrid = Center(child: Stack(children: gridStack));

    List<Widget> rowLabels = <Widget>[];
    if (boardInset > 0) {
      rowLabels.add(Container(
          constraints: BoxConstraints.tightFor(width: rowLabelWidth, height: boardInset)));
    }
    for (int i = 8; i >= 1; i--) {
      rowLabels.add(Container(
          constraints: BoxConstraints.tightFor(width: rowLabelWidth, height: squareSize),
          alignment: Alignment.center,
          child: Center(child: Text(i.toString())
          )));
    }

    List<Widget> colLabels = <Widget>[];
    for (int i = 0; i < 8; i++) {
      colLabels.add(Container(
          constraints: BoxConstraints.tightFor(width: squareSize, height: colLabelHeight),
          alignment: Alignment.center,
          child: Center(child: Text('abcdefgh'[i])
          )));
    }

    return Container(
        constraints: BoxConstraints.tightFor(width: size, height: size),
        child: Row(
            children: <Widget>[
              SizedBox(width: rowLabelWidth, child: ListView(children: rowLabels)),
              Expanded(child: Column(
                  children: <Widget>[Expanded(child: boardGrid), Row(children: colLabels)]
              ))
            ]
        )
    );
  }
}
