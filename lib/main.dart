// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'chessboard.dart';
import 'model/board.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<MyAppState>()
      : context.findAncestorStateOfType<MyAppState>();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static Board board = Board();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ChessBoard',
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Chess'),
            ),
            body: Chessboard(board),
            persistentFooterButtons: <Widget>[
              IconButton(
                icon: const Icon(Icons.replay_circle_filled),
                onPressed: () {
                  setState(() { board.reset(); });
                },
              )
            ]
        )
    );
  }
}