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

      // Filter hanya file mp3 di folder audios
      final List<String> mp3Paths = manifestMap.keys
          .where((String key) => key.contains('assets/audios/') && key.endsWith('.mp3'))
          .toList();

      final List<Map<String, String>> loadedSongs = mp3Paths.map((path) {
        // Decode path agar spasi (%20) kembali jadi spasi asli
        final String decodedPath = Uri.decodeComponent(path);
        
        String fileName = decodedPath.split('/').last.replaceAll('.mp3', '');
        
        // Membersihkan judul dari karakter aneh (-, _, ( ), dll)
        String title = fileName.replaceAll(RegExp(r'[_\-\(\)]'), ' ').trim();
        
        if (title.isNotEmpty) {
          title = title[0].toUpperCase() + title.substring(1);
        }

        return {
          "title": title,
          "artist": "Sumbawa Music",
          "url": decodedPath,
          // Logika kategori: Cek kata 'dj' di nama file
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
          
          // --- 1. MENU KATEGORI (Hanya 2) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _buildCategoryItem("Lagu Sumbawa", Icons.music_note, Colors.greenAccent)),
                const SizedBox(width: 15),
                Expanded(child: _buildCategoryItem("DJ Sumbawa", Icons.headphones, Colors.orangeAccent)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- 2. KOLOM PENCARIAN ---
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
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white38, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    ) 
                  : null,
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

          const SizedBox(height: 15),
          
          // --- 3. DAFTAR LAGU ---
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : filteredSongs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off, color: Colors.white12, size: 80),
                        const SizedBox(height: 10),
                        Text("Lagu tidak ditemukan", style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    itemCount: filteredSongs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      var song = filteredSongs[index];
                      return ListTile(
                        onTap: () => widget.onSongTap(song['title']!, song['artist']!, song['url']!),
                        tileColor: Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.redAccent),
                        ),
                        title: Text(
                          song['title']!, 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.black : color, size: 20),
            const SizedBox(width: 8),
            Text(
              name, 
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white, 
                fontSize: 13, 
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
      ),
    );
  }
}
