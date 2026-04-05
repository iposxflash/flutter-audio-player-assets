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
        scaffoldBackgroundColor: const Color(0xFF121212),
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
  // Inisialisasi AudioPlayer tunggal agar bisa diakses di MiniPlayer
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String _selectedCategory = "Sasak";
  String _currentTitle = "Pilih Lagu Sasak";
  String _currentArtist = "Klik untuk memutar";

  // Perbaikan: Menggunakan setAsset karena file ada di folder assets/audios/
  void _playMusic(String title, String artist, String assetPath) async {
    try {
      // PERBAIKAN: Gunakan setAsset bukan setUrl untuk file lokal
      await _audioPlayer.setAsset(assetPath);
      _audioPlayer.play();
      
      setState(() {
        _currentTitle = title;
        _currentArtist = artist;
      });
    } catch (e) {
      debugPrint("Error memutar musik aset: $e");
      // Tambahkan SnackBar jika file tidak ditemukan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memutar: $title. Cek folder assets!")),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Bersihkan memori saat aplikasi ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. KONTEN UTAMA (HOME SCREEN)
          SafeArea(
            bottom: false, // Biar konten bisa "mengalir" ke bawah MiniPlayer
            child: HomeScreen(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (newCategory) {
                setState(() => _selectedCategory = newCategory);
              },
              onSongTap: (title, artist, assetPath) {
                // Parameter 'url' diubah jadi 'assetPath' agar sesuai logika lokal
                _playMusic(title, artist, assetPath);
              },
            ),
          ),
          
          // 2. MINI PLAYER (Melayang di bawah)
          // Dibungkus Padding agar tidak terlalu mepet ke bawah jika ada navigasi sistem
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MiniPlayer(
                player: _audioPlayer,
                songTitle: _currentTitle,
                artist: _currentArtist,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
