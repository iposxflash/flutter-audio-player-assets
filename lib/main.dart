import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Pastikan sudah install di pubspec.yaml
import 'screens/home_screen.dart';
import 'widgets/mini_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musik Sasak',
      theme: ThemeData(
        brightness: Brightness.dark, // Tema gelap lebih keren untuk app musik
        primaryColor: Colors.redAccent,
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

// Ini adalah Wrapper yang membungkus HomeScreen dan Mini Player (Footer)
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Satu player untuk seluruh app

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body utama tetap HomeScreen
      body: Stack(
        children: [
          const HomeScreen(), 
          
          // Bagian FOOTER (Mini Player) yang melayang di bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(player: _audioPlayer),
          ),
        ],
      ),
    );
  }
}
