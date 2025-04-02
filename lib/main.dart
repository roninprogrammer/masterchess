import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masterchess/screens/ChessScreen.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(DeepChessApp());
}

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
