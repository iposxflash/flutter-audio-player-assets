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
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<String> mp3Paths = manifestMap.keys
          .where((String key) => key.contains('assets/audios/') && key.endsWith('.mp3'))
          .toList();

      final List<Map<String, String>> loadedSongs = mp3Paths.map((path) {
        String fileName = path.split('/').last.replaceAll('.mp3', '');
        String title = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
        title = title[0].toUpperCase() + title.substring(1);

        return {
          "title": title,
          "artist": "Musik Sasak",
          "url": path,
          // Menambahkan label kategori otomatis (Default: Sasak)
          "category": path.contains('pop') ? "Pop" : "Sasak", 
        };
      }).toList();

      setState(() {
        _allSongs = loadedSongs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter berdasarkan KATEGORI yang dipilih (Sasak/Pop/Lainnya)
    final categorySongs = _allSongs.where((song) {
      if (widget.selectedCategory == "Lainnya") return true; // Tampilkan semua jika pilih 'Lainnya'
      return song['category'] == widget.selectedCategory;
    }).toList();

    // 2. Filter berdasarkan PENCARIAN
    final filteredSongs = categorySongs.where((song) {
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
          // --- FITUR PENCARIAN ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari lagu...",
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- MENU KATEGORI YANG HILANG (DIKEMBALIKAN) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem("Sasak", Icons.terrain, Colors.greenAccent),
                _buildCategoryItem("Pop", Icons.music_note, Colors.orangeAccent),
                _buildCategoryItem("Lainnya", Icons.library_music, Colors.blueAccent),
              ],
            ),
          ),

          const SizedBox(height: 25),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
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
                      leading: const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 40),
                      title: Text(song['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white60)),
                    );
                  },
                ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    bool isSelected = widget.selectedCategory == name;
    return GestureDetector(
      onTap: () => widget.onCategoryChanged(name),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isSelected ? Colors.black : color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}
