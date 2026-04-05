import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  // Tambahkan callback agar saat lagu diklik, main.dart tahu lagu apa yang diputar
  final Function(String title, String artist, String url) onSongTap;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const HomeScreen({
    super.key, 
    required this.onSongTap,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data lagu tetap di sini atau bisa dipindah ke model terpisah
  final Map<String, List<Map<String, String>>> songs = {
    "Sasak": [
      {"title": "Kadal Nongaq", "artist": "Artis Sasak 1", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"},
      {"title": "Lalo Nganteni", "artist": "Artis Sasak 2", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"},
    ],
    "Pop": [
      {"title": "Lagu Pop 1", "artist": "Penyanyi Pop", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"},
    ],
    "Lainnya": [
      {"title": "Instrumen Gamelan", "artist": "Tradisional", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Gunakan widget.selectedCategory karena state dikontrol dari main.dart
    final currentSongs = songs[widget.selectedCategory] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Bagian 1: 3 Kategori
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryItem("Sasak", Icons.terrain, Colors.green),
              _buildCategoryItem("Pop", Icons.music_note, Colors.orange),
              _buildCategoryItem("Lainnya", Icons.library_music, Colors.blue),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Daftar Lagu", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
        ),
        const SizedBox(height: 10),

        // Bagian 2: List Lagu
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: currentSongs.length,
            itemBuilder: (context, index) {
              var song = currentSongs[index];
              return Card(
                elevation: 0,
                color: Colors.grey[50],
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.red),
                  ),
                  title: Text(
                    song['title']!, 
                    style: const TextStyle(fontWeight: FontWeight.w600)
                  ),
                  subtitle: Text(song['artist']!),
                  trailing: const Icon(Icons.more_vert, color: Colors.grey),
                  onTap: () {
                    // Panggil fungsi play yang ada di main.dart
                    widget.onSongTap(
                      song['title']!, 
                      song['artist']!, 
                      song['url']!
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Beri space agar tidak tertutup Mini Player
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    bool isSelected = widget.selectedCategory == name;
    return GestureDetector(
      onTap: () => widget.onCategoryChanged(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected 
                    ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] 
                    : [],
              ),
              child: Icon(
                icon, 
                color: isSelected ? Colors.white : color, 
                size: 32
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name, 
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
              )
            ),
          ],
        ),
      ),
    );
  }
}
