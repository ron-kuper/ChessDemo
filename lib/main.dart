// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  @override
  Widget build(BuildContext context) {

    var squares = <Container>[];
    var light = Color(0xFFEEEDD3);
    var dark =  Color(0xFF7C9B5F);
    bool isLight = true;

    for (int i = 0; i < 8; i++) {
      var isSqLight = isLight;
      for (int j = 0; j < 8; j++) {
        // Determine what piece to place here
        var child;
        if (i < 2 || i > 5) {
          var color = (i < 2) ? 'd' : 'l';
          var piece;
          if (i == 1 || i == 6) {
            piece = 'p';
          } else {
            const pieces = ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'];
            piece = pieces[j];
          }
          child = SvgPicture.asset('assets/images/Chess_' + piece + color + 't45.svg');
        }
        var square = Container(
            padding: const EdgeInsets.all(0),
            child: child,
            color: isSqLight ? light : dark);
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
