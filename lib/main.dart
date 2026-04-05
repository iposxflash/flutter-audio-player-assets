import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'home_screen.dart'; // Sesuaikan path jika di folder screens/
import 'widgets/mini_player.dart'; // Sesuaikan path jika di folder widgets/

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
  
  // State untuk mengontrol data dari HomeScreen
  String _selectedCategory = "Sasak";
  String _currentTitle = "Pilih Lagu";
  String _currentArtist = "Klik untuk memutar";

  // Fungsi untuk memutar lagu yang dipanggil dari HomeScreen
  void _playMusic(String title, String artist, String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
      setState(() {
        _currentTitle = title;
        _currentArtist = artist;
      });
    } catch (e) {
      debugPrint("Error playing audio: $e");
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
      // Menggunakan Stack agar MiniPlayer melayang di atas konten
      body: Stack(
        children: [
          // 1. HOME SCREEN (Konten Utama)
          HomeScreen(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (newCategory) {
              setState(() => _selectedCategory = newCategory);
            },
            onSongTap: (title, artist, url) {
              _playMusic(title, artist, url);
            },
          ),
          
          // 2. MINI PLAYER (Footer)
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
