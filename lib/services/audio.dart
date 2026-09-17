import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loud_beat/database/database_helper.dart';
import 'dart:typed_data';

class AudioService {

  List queue = [];
  final ValueNotifier<Song?> currentSong = ValueNotifier(null);
  final ValueNotifier<Uint8List?> currentAlbumCover = ValueNotifier(null);

  final ValueNotifier<bool> isMusicPlaying = ValueNotifier(false);

  AudioService() {
    player.playingStream.listen((playing) {
      isMusicPlaying.value = playing;
      print("PLAYING: $playing");
    });
  }
  



  final AudioPlayer player = AudioPlayer();





  Future<void> dispose() async {
    await player.dispose();
  }

  Future<void> shuffleQueue() async {
    List<Song> songs = await getSongs();
    songs.shuffle();
    queue = songs;

    print("QUEUE ${queue}");
  }

  void emptyQueue()  {
    queue = [];
    currentSong.value = null;
    currentAlbumCover.value = null;
  }

  Future<void> addToQueue(int songId) async {
    Song? song = await getSong(songId);
    print(song!.title);
    queue.add(song);
  }

  Future<void> playNextSong() async {
    if (queue.isEmpty) return;

    final Song nextSong = queue.removeAt(0);
    currentSong.value = nextSong;
    currentAlbumCover.value = await getAlbumCover(currentSong.value!.filePath);

    await player.setFilePath(nextSong.filePath);
    await player.setVolume(1.0);
    await player.play();

    await player.processingStateStream
        .firstWhere((state) => state == ProcessingState.completed);
      
    currentSong.value = null;
    currentAlbumCover.value = null;

    await playNextSong();
}

}


final audioService = AudioService();