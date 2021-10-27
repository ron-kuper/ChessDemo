// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chessboard.dart';
import 'model/board.dart';

void main() => runApp(const ChessAppProvider());

class ChessAppProvider extends StatelessWidget {
  const ChessAppProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BoardModel())
        ],
        child: const ChessApp()
    );
  }
}

class ChessApp extends StatelessWidget {
  const ChessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessBoard',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Chess'),
          ),
          body: const Chessboard(),
          persistentFooterButtons: <Widget>[
            IconButton(
              icon: const Icon(Icons.replay_circle_filled),
              onPressed: () {
                context.read<BoardModel>().reset();
              })
          ]
      )
    );
  }
}