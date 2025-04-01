import 'package:flutter/material.dart';
import 'package:masterchess/screens/ChessScreen.dart';

void main() => runApp(const DeepChessApp());

class DeepChessApp extends StatelessWidget {
  const DeepChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepChess AI',
      theme: ThemeData.dark(),
      home: const ChessScreen(),
    );
  }
}
