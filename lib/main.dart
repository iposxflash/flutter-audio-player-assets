import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'home_screen.dart'; 

Future<void> main() async {
  // 1. Agar aplikasi tidak blank saat start
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi notifikasi kontrol musik
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ojgrup.musiksasak.audio', 
      androidNotificationChannelName: 'Musik Playback',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint("Background init error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musik Sumbawa',
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
  String _selectedCategory = "Lagu Sumbawa"; 

  // --- PERBAIKAN FUNGSI PUTAR MUSIK ---
  void _playMusic(String title, String artist, String assetPath) async {
    try {
      // Kita pastikan path dibersihkan lagi sebelum dikirim ke player
      final String cleanAssetPath = assetPath.trim();

      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          // Gunakan Uri.parse dengan skema asset:/// agar lebih kompatibel dengan nama file panjang
          Uri.parse('asset:///$cleanAssetPath'),
          tag: MediaItem(
            id: cleanAssetPath, 
            album: "Sumbawa Music",
            title: title,
            artist: artist,
            artUri: Uri.parse("asset:///assets/images/logo.png"), 
          ),
        ),
      );
      
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playback: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memutar: $title"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
      body: SafeArea(
        bottom: false,
        child: HomeScreen(
          player: _audioPlayer, 
          selectedCategory: _selectedCategory,
          onCategoryChanged: (newCategory) {
            setState(() => _selectedCategory = newCategory);
          },
          onSongTap: (title, artist, assetPath) {
            _playMusic(title, artist, assetPath);
          },
        ),
      ),
    );
  }
}
