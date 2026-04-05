import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class HomeScreen extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final Function(String title, String artist, String url) onSongTap;
  final AudioPlayer player; // Kita butuh akses ke player untuk footer

  const HomeScreen({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSongTap,
    required this.player,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<Map<String, String>> _allSongs = [];
  bool _isLoading = true;

  // Data untuk footer (diambil otomatis saat lagu diklik)
  String _currentTitle = "";
  String _currentArtist = "";

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
        final String decodedPath = Uri.decodeComponent(path);
        String fileName = decodedPath.split('/').last.replaceAll('.mp3', '');
        String title = fileName.replaceAll(RegExp(r'[_\-\(\)]'), ' ').trim();
        
        if (title.isNotEmpty) {
          title = title[0].toUpperCase() + title.substring(1);
        }

        return {
          "title": title,
          "artist": "Sumbawa Music",
          "url": path,
          "category": decodedPath.toLowerCase().contains('dj') ? "DJ Sumbawa" : "Lagu Sumbawa", 
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
    final filteredSongs = _allSongs.where((song) {
      final isCategory = song['category'] == widget.selectedCategory;
      final isSearch = song['title']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return isCategory && isSearch;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
              ),
            ),
          ),

          // 2. Konten Utama
          Column(
            children: [
              const SizedBox(height: 50),
              // KATEGORI
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
              const SizedBox(height: 15),
              // PENCARIAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari lagu...",
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.07),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),
              // LIST LAGU
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                  : ListView.separated(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                      itemCount: filteredSongs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        var song = filteredSongs[index];
                        return ListTile(
                          onTap: () {
                            setState(() {
                              _currentTitle = song['title']!;
                              _currentArtist = song['artist']!;
                            });
                            widget.onSongTap(song['title']!, song['artist']!, song['url']!);
                          },
                          tileColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          leading: const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 40),
                          title: Text(song['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white60)),
                        );
                      },
                    ),
              ),
            ],
          ),

          // 3. FOOTER (MINI PLAYER) - Muncul jika ada lagu yang dipilih
          if (_currentTitle.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 15,
              right: 15,
              child: _buildFooterPlayer(),
            ),
        ],
      ),
    );
  }

  Widget _buildFooterPlayer() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_currentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(_currentArtist, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          StreamBuilder<PlayerState>(
            stream: widget.player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 40),
                onPressed: () => playing ? widget.player.pause() : widget.player.play(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    bool isSelected = widget.selectedCategory == name;
    return GestureDetector(
      onTap: () => widget.onCategoryChanged(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.black : color, size: 20),
            const SizedBox(width: 8),
            Text(name, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
