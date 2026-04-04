import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "Sasak"; // Kategori default

  // Data dummy lagu berdasarkan kategori
  final Map<String, List<Map<String, String>>> songs = {
    "Sasak": [
      {"title": "Kadal Nongaq", "artist": "Artis Sasak 1", "file": "sasak1.mp3"},
      {"title": "Lalo Nganteni", "artist": "Artis Sasak 2", "file": "sasak2.mp3"},
    ],
    "Pop": [
      {"title": "Lagu Pop 1", "artist": "Penyanyi Pop", "file": "pop1.mp3"},
    ],
    "Lainnya": [
      {"title": "Instrumen Gamelan", "artist": "Tradisional", "file": "ukulele.mp3"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Musik Sasak", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Daftar Lagu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // Bagian 2: List Lagu
          Expanded(
            child: ListView.builder(
              itemCount: songs[selectedCategory]?.length ?? 0,
              itemBuilder: (context, index) {
                var song = songs[selectedCategory]![index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
                  title: Text(song['title']!),
                  subtitle: Text(song['artist']!),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // Logika untuk memutar lagu di Footer nanti
                    print("Memutar: ${song['title']}");
                  },
                );
              },
            ),
          ),
          
          // Beri jarak di bawah agar tidak tertutup Footer
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Widget untuk tombol Kategori
  Widget _buildCategoryItem(String name, IconData icon, Color color) {
    bool isSelected = selectedCategory == name;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = name),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Icon(icon, color: isSelected ? Colors.white : color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
