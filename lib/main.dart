// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'board.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ChessBoard',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Chess'),
          ),
          body: const Center(
            child: Chessboard(),
          ),
        ),
      );
  }
}


class Chessboard extends StatefulWidget {
  const Chessboard({Key? key}) : super(key: key);

  @override
  _ChessboardState createState() => _ChessboardState();
}

class _ChessboardState extends State<Chessboard> {
  var _board = Board();
  int? _iTap = null;
  int? _jTap = null;

  @override
  Widget build(BuildContext context) {
    var squares = <GestureDetector>[];
    var light = Color(0xFFEEEDD3);
    var dark =  Color(0xFF7C9B5F);
    var hilite = Colors.red;
    bool isLight = true;

    for (int i = 0; i < 8; i++) {
      var isSqLight = isLight;
      for (int j = 0; j < 8; j++) {
        // Determine what piece to place here
        var child;
        if (_board[i][j] != Piece.empty) {
          var pieceColor = _board[i][j].toString().substring(6);
          child = SvgPicture.asset('assets/images/Chess_' + pieceColor + 't45.svg');
        }
        var color;
        if (i == _iTap && j == _jTap) {
          color = hilite;
        } else {
          color = isSqLight ? light : dark;
        }
        var square = GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(0),
              child: child,
              color: color),
            onTap: () {
              setState(() {
                if (_iTap == i && _jTap == j) {
                  _iTap = null;
                  _jTap = null;
                } else {
                  _iTap = i;
                  _jTap = j;
                }
              });
            }
            );
        isSqLight = !isSqLight;
        squares.add(square);
      }
      isLight = !isLight;
    }

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      crossAxisCount: 8,
      children: squares,
    );
  }
}
