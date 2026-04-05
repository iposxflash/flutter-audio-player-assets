import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final Function(String title, String artist, String url) onSongTap;

  HomeScreen({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSongTap,
  });

  // Data lagu menggunakan URL streaming agar bisa langsung dicoba
  final Map<String, List<Map<String, String>>> songs = {
    "Sasak": [
      {
        "title": "Kadal Nongaq",
        "artist": "Artis Sasak 1",
        "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
      },
      {
        "title": "Lalo Nganteni",
        "artist": "Artis Sasak 2",
        "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"
      },
    ],
    "Pop": [
      {
        "title": "Lagu Pop 1",
        "artist": "Penyanyi Pop",
        "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"
      },
    ],
    "Lainnya": [
      {
        "title": "Instrumen Gamelan",
        "artist": "Tradisional",
        "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentSongs = songs[selectedCategory] ?? [];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // --- BAGIAN KATEGORI (HORIZONTAL) ---
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
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Daftar Lagu",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // --- DAFTAR LAGU (RESPONSIF) ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentSongs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                var song = currentSongs[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => onSongTap(
                        song['title']!,
                        song['artist']!,
                        song['url']!,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.redAccent, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song['artist']!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.more_vert,
                                color: Colors.white.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // --- RUANG KOSONG (PENTING) ---
          // SizedBox ini memastikan lagu terbawah bisa di-scroll melewati MiniPlayer
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    bool isSelected = selectedCategory == name;
    return GestureDetector(
      onTap: () => onCategoryChanged(name),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5))
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.black87 : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
