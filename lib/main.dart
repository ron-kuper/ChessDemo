import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_demo/screens/chessboard.dart';
import 'package:chess_demo/models/board.dart';
import 'package:chess_demo/models/valid_moves.dart';

void main() => runApp(const ChessAppProvider());

class ChessAppProvider extends StatelessWidget {
  const ChessAppProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoardModel boardModel = BoardModel();
    ValidMovesModel validMovesModel = ValidMovesModel(boardModel);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => boardModel),
          ChangeNotifierProvider(create: (context) => validMovesModel)
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
            TextButton.icon(
              icon: const Icon(Icons.replay_circle_filled),
              label:  const Text('Reset'),
              onPressed: () {
                context.read<BoardModel>().reset();
                context.read<ValidMovesModel>().reset();
              })
          ]
      )
    );
  }
}