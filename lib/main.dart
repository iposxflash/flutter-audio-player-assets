import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'home_screen.dart'; 
import 'widgets/mini_player.dart'; 

Future<void> main() async {
  // Pastikan binding siap agar tidak blank putih
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi kontrol musik
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ojgrup.musiksasak.channel.audio',
      androidNotificationChannelName: 'Musik Sasak Audio Playback',
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

  void _playMusic(String title, String artist, String assetPath) async {
    try {
      // Setup audio source dengan metadata untuk notifikasi
      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: MediaItem(
            id: assetPath, 
            album: "Musik Sasak",
            title: title,
            artist: artist,
            // Hapus baris artUri di bawah jika file logo.png belum ada di assets/images/
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: File audio tidak ditemukan atau rusak")),
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
          
          // Mini Player melayang di bawah
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
