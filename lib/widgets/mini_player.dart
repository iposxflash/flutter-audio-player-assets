import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayer player;
  final String songTitle;
  final String artist;

  const MiniPlayer({
    super.key,
    required this.player,
    required this.songTitle,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Sembunyikan MiniPlayer jika belum ada lagu yang dipilih
    // Sesuai dengan nilai default di main.dart yaitu "Pilih Lagu"
    if (songTitle == "Pilih Lagu") return const SizedBox.shrink();

    return Container(
      height: 75,
      // Margin bawah agak tinggi agar tidak menutupi navigasi sistem HP
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 15),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        // Menggunakan Gradient agar terlihat lebih mewah
        gradient: const LinearGradient(
          colors: [Colors.redAccent, Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          // Ikon musik dengan animasi sederhana
          const Icon(Icons.music_note, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  songTitle,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Colors.white70, 
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Tombol Kontrol Play/Pause
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;

              // Tampilkan Loading jika lagu sedang dimuat
              if (processingState == ProcessingState.buffering ||
                  processingState == ProcessingState.loading) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 30.0,
                  height: 30.0,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 40),
                  onPressed: player.pause,
                );
              } else {
                // Jika lagu selesai, tampilkan tombol replay
                return IconButton(
                  icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 35),
                  onPressed: () => player.seek(Duration.zero),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
