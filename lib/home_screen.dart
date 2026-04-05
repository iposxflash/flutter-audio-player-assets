import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final Function(String title, String artist, String url) onSongTap;

  const HomeScreen({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSongTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<Map<String, String>> _allSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets(); // Panggil fungsi baca aset saat start
  }

  // FUNGSI INTI: Membaca daftar file mp3 dari folder assets secara otomatis
  Future<void> _loadAssets() async {
    try {
      // 1. Ambil manifest aset dari Flutter
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 2. Filter hanya file yang ada di folder assets/audios/ dan berakhiran .mp3
      final List<String> mp3Paths = manifestMap.keys
          .where((String key) => key.contains('assets/audios/') && key.endsWith('.mp3'))
          .toList();

      // 3. Ubah path file menjadi objek lagu (Title diambil dari nama file)
      final List<Map<String, String>> loadedSongs = mp3Paths.map((path) {
        // Mengambil nama file saja: assets/audios/lagu_sasak.mp3 -> lagu_sasak
        String fileName = path.split('/').last.replaceAll('.mp3', '');
        // Percantik tampilan: ganti underscore/strip jadi spasi dan huruf kapital
        String title = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
        title = title[0].toUpperCase() + title.substring(1);

        return {
          "title": title,
          "artist": "Musik Sasak", // Artis bisa diset default atau ambil dari meta nantinya
          "url": path,
        };
      }).toList();

      setState(() {
        _allSongs = loadedSongs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal baca aset: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter pencarian
    final filteredSongs = _allSongs.where((song) {
      final title = song['title']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Kolom Pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari lagu otomatis...",
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : filteredSongs.isEmpty
                ? const Center(child: Text("Tidak ada file .mp3 di assets/audios/", style: TextStyle(color: Colors.white54)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSongs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var song = filteredSongs[index];
                      return ListTile(
                        onTap: () => widget.onSongTap(song['title']!, song['artist']!, song['url']!),
                        tileColor: Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        leading: const Icon(Icons.music_note, color: Colors.redAccent),
                        title: Text(song['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        trailing: const Icon(Icons.play_circle_fill, color: Colors.redAccent),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}
