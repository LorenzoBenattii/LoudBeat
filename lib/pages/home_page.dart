
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loud_beat/database/database_helper.dart';

import 'package:loud_beat/services/audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<Song?>(
          valueListenable: audioService.currentSong,
          builder: (context, currentSong, child) {
            return Column(
              children: [
                const SizedBox(height: 30),

                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: audioService.currentAlbumCover.value != null
                        ? Image.memory(
                            audioService.currentAlbumCover.value!,
                            width: 320,
                            height: 320,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 320,
                            height: 320,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.music_note,
                              size: 100,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  currentSong?.title ?? "No Song playing",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                if (currentSong != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.fast_rewind),
                      ),

                      const SizedBox(width: 10),

                      ValueListenableBuilder<bool>(
                        valueListenable: audioService.isMusicPlaying,
                        builder: (context, isPlaying, child) {
                          return IconButton(
                            onPressed: () {
                              if (isPlaying) {
                                audioService.player.pause();
                              } else {
                                audioService.player.play();
                              }
                            },
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 10),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.fast_forward),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

