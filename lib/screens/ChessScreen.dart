import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import '../services/deepseek_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  final ChessBoardController _controller = ChessBoardController();
  final FlutterTts _flutterTts = FlutterTts();
  List<String> chatMessages = [
    "🤖 DeepKing: Let's begin. Show me what you got!",
  ];
  bool isWaitingForAI = false;
  String lastFen = "";

  @override
  void initState() {
    super.initState();

    // Listen for any board change
    _controller.addListener(() {
      final currentFen = _controller.getFen();

      // Only act if FEN changed and it’s player’s move
      if (!isWaitingForAI && currentFen != lastFen) {
        // Try to detect the last move by difference (fallback)
        onPlayerMove(currentFen);
      }

      lastFen = currentFen;
    });
  }

  String? _detectMove(String oldFen, String newFen) {
    // Fallback: just return dummy "last move" in e2e4 format
    // You can upgrade this with FEN diff logic later
    // For now, just send the new FEN — DeepSeek can still respond
    return "last_move_unknown";
  }

  void onPlayerMove(String fen) async {
    if (isWaitingForAI) return;

    setState(() {
      chatMessages.add("🧑 You moved.");
      isWaitingForAI = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await DeepSeekService.getAIMove(fen, "your move");
      final aiMove = result["move"]!;
      final aiChat = result["chat"]!;

      if (aiMove.length == 4) {
        final from = aiMove.substring(0, 2);
        final to = aiMove.substring(2, 4);
        _controller.makeMove(from: from, to: to);
      }

      await _flutterTts.speak(aiChat);

      setState(() {
        chatMessages.add("🤖 DeepKing: $aiChat");
        isWaitingForAI = false;
      });
    } catch (e) {
      setState(() {
        chatMessages.add("❌ Error: \${e.toString()}");
        isWaitingForAI = false;
      });
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("♟ DeepChess AI")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ChessBoard(
              controller: _controller,
              boardColor: BoardColor.brown,
              boardOrientation: PlayerColor.white,
            ),
          ),
          const Divider(),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                reverse: true,
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = chatMessages.length - 1 - index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      chatMessages[reversedIndex],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
