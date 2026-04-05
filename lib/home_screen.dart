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
        // Decode path agar spasi (%20) kembali jadi spasi asli
        final String decodedPath = Uri.decodeComponent(path);
        
        String fileName = decodedPath.split('/').last.replaceAll('.mp3', '');
        String title = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
        
        if (title.isNotEmpty) {
          title = title[0].toUpperCase() + title.substring(1);
        }

        return {
          "title": title,
          "artist": "Sumbawa Music",
          "url": decodedPath,
          // LOGIKA KATEGORI: Jika nama file ada kata 'dj', masuk ke 'DJ Sumbawa'
          "category": decodedPath.toLowerCase().contains('dj') ? "DJ Sumbawa" : "Lagu Sumbawa", 
        };
      }).toList();

      setState(() {
        _allSongs = loadedSongs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading assets: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter Kategori
    final categorySongs = _allSongs.where((song) {
      return song['category'] == widget.selectedCategory;
    }).toList();

    // 2. Filter Pencarian
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
          const SizedBox(height: 25),
          
          // --- 1. MENU KATEGORI (Hanya 2 Kategori) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryItem("Lagu Sumbawa", Icons.music_note, Colors.greenAccent),
                _buildCategoryItem("DJ Sumbawa", Icons.headphones, Colors.orangeAccent),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- 2. KOLOM PENCARIAN (Sekarang di bawah kategori) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari di ${widget.selectedCategory}...",
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent, size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),
          
          // --- 3. DAFTAR LAGU ---
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : filteredSongs.isEmpty
                ? const Center(child: Text("Belum ada lagu di kategori ini", style: TextStyle(color: Colors.white54)))
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    itemCount: filteredSongs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var song = filteredSongs[index];
                      return ListTile(
                        onTap: () => widget.onSongTap(song['title']!, song['artist']!, song['url']!),
                        tileColor: Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          child: const Icon(Icons.play_arrow, color: Colors.white),
                        ),
                        title: Text(
                          song['title']!, 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        trailing: const Icon(Icons.more_vert, color: Colors.white38),
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
      onTap: () {
        _searchController.clear();
        setState(() => _searchQuery = "");
        widget.onCategoryChanged(name);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)] : [],
            ),
            child: Icon(icon, color: isSelected ? Colors.black : color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            name, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60, 
              fontSize: 12, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }
}
