import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'home_screen.dart'; 
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Warna gelap pekat
        primaryColor: Colors.redAccent,
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String _selectedCategory = "Sasak";
  String _currentTitle = "Pilih Lagu";
  String _currentArtist = "Klik untuk memutar";

  void _playMusic(String title, String artist, String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
      setState(() {
        _currentTitle = title;
        _currentArtist = artist;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack untuk melapis konten dan player
      body: Stack(
        children: [
          // 1. HOME SCREEN (Konten Utama)
          // Membungkus dengan SafeArea agar tidak tertutup notch/status bar
          SafeArea(
            child: HomeScreen(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (newCategory) {
                setState(() => _selectedCategory = newCategory);
              },
              onSongTap: (title, artist, url) {
                _playMusic(title, artist, url);
              },
            ),
          ),
          
          // 2. MINI PLAYER (Melayang di bawah)
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(
              player: _audioPlayer,
              songTitle: _currentTitle,
              artist: _currentArtist,
            ),
          ),
        ],
      ),
    );
  }
}
