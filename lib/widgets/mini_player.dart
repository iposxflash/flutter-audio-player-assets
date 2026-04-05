import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayer player;
  final String songTitle;

  const MiniPlayer({super.key, required this.player, required this.songTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle, color: Colors.white, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              songTitle,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                onPressed: () => playing ? player.pause() : player.play(),
              );
            },
          ),
        ],
      ),
    );
  }
}
