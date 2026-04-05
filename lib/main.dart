import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'home_screen.dart'; 
import 'widgets/mini_player.dart'; 

Future<void> main() async {
  // 1. WAJIB: Agar aplikasi tidak blank saat start
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi notifikasi kontrol musik di bar atas
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
  
  // PERBAIKAN: Default category sekarang "Lagu Sumbawa" sesuai HomeScreen terbaru
  String _selectedCategory = "Lagu Sumbawa"; 
  String _currentTitle = "Pilih Lagu";
  String _currentArtist = "Klik untuk memutar";

  void _playMusic(String title, String artist, String assetPath) async {
    try {
      // 3. Set AudioSource dengan Metadata agar muncul di notifikasi
      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: MediaItem(
            id: assetPath, 
            album: "Sumbawa Music",
            title: title,
            artist: artist,
            // Pastikan ada file assets/images/logo.png
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
      debugPrint("Error playback: $e");
      // Menampilkan pesan error jika file tidak bisa diputar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: File audio tidak ditemukan atau rusak"),
            backgroundColor: Colors.red,
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
      // 4. Menggunakan Stack agar MiniPlayer melayang di bagian bawah
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
