import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart'; // Tambahkan ini
import 'home_screen.dart'; 
import 'widgets/mini_player.dart'; 

// Ubah main menjadi async untuk inisialisasi background service
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INI KUNCINYA: Inisialisasi agar "tanda di atas" muncul
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ojgrup.musiksasak.channel.audio',
    androidNotificationChannelName: 'Musik Sasak Audio Playback',
    androidNotificationOngoing: true, // Notifikasi tidak bisa dihapus saat musik jalan
  );

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String _selectedCategory = "Sasak";
  String _currentTitle = "Pilih Lagu Sasak";
  String _currentArtist = "Klik untuk memutar";

  // Perbaikan fungsi play agar data lagu terkirim ke sistem notifikasi Android
  void _playMusic(String title, String artist, String assetPath) async {
    try {
      // PERBAIKAN: Gunakan AudioSource.asset agar notifikasi muncul
      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: MediaItem(
            // Data di bawah ini yang akan muncul di "Tanda di Atas"
            id: assetPath, 
            album: "Musik Sasak",
            title: title,
            artist: artist,
            // Pastikan ada file logo di folder assets/images/
            artUri: Uri.parse("asset:///assets/images/logo.png"), 
          ),
        ),
      );
      
      _audioPlayer.play();
      
      setState(() {
        _currentTitle = title;
        _currentArtist = artist;
      });
    } catch (e) {
      debugPrint("Error memutar musik: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memutar musik. Cek file aset!")),
      );
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
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: HomeScreen(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (newCategory) {
                setState(() => _selectedCategory = newCategory);
              },
              onSongTap: (title, artist, assetPath) {
                _playMusic(title, artist, assetPath);
              },
            ),
          ),
          
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
