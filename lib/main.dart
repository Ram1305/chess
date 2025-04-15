import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:chess_game/ui/screens/home_screen.dart'
// import 'package:chess_game/ui/theme.dart';
import 'package:instavideo/ui/home_screen.dart';
import 'package:instavideo/ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Game',
      theme: ChessTheme.lightTheme,
      darkTheme: ChessTheme.darkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
