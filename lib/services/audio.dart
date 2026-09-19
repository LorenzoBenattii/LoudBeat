import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loud_beat/database/database_helper.dart';
import 'dart:typed_data';

class AudioService {
  List<Song> queue = [];
  int index = -1;

  final ValueNotifier<Song?> currentSong = ValueNotifier(null);
  final ValueNotifier<Uint8List?> currentAlbumCover = ValueNotifier(null);
  final ValueNotifier<bool> isMusicPlaying = ValueNotifier(false);

  final AudioPlayer player = AudioPlayer();

  bool isChangingSong = false;

  AudioService() {
    player.playingStream.listen((playing) {
      isMusicPlaying.value = playing;
      print("PLAYING: $playing");
    });

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNextSong();
      }
    });
  }

  Future<void> _playCurrentSong() async {
    if (index < 0 || index >= queue.length) return;

    final Song song = queue[index];


    currentSong.value = song;
    currentAlbumCover.value = await getAlbumCover(song.filePath);

    try {
      await player.setFilePath(song.filePath);
      await player.setVolume(1.0);
      await player.play();
    } on PlayerInterruptedException {
      print("Player load interrupted");
    }
  }

  Future<void> playNextSong() async {
    if (queue.isEmpty || isChangingSong) return;

    isChangingSong = true;

    if (index >= queue.length -1 ) {
      index = 0;
    } else {
      index++;
    }

    final int requestedIndex = index;
    isChangingSong = false;
    await _playSong(requestedIndex);
  }

  Future<void> _playSong(int requestedIndex) async {
    if (requestedIndex <0 || requestedIndex >= queue.length) return;

    final Song song = queue[requestedIndex];

    currentSong.value = song;
    currentAlbumCover.value = await getAlbumCover(song.filePath);

    try {
      await player.setFilePath(song.filePath);
      await player.setVolume(1.0);

      if (index != requestedIndex) return;
      await player.play();
    } on PlayerInterruptedException {
      print("Song loading interrupted");
    }

  }
    

  Future<void> goToPreviousSong() async {
    if (queue.isEmpty || isChangingSong) return;

    isChangingSong = true;

    if (player.position > const Duration(seconds: 3)) {
      isChangingSong = false;
      await player.seek(Duration.zero);
      return;
    }

    if (index <= 0) {
      index = queue.length -1;
    } else {
      index--;
    }

    final int requestedIndex = index;
    isChangingSong = false;

    await _playSong(requestedIndex);
  }



  Future<void> shuffleQueue() async {
    List<Song> songs = await getSongs();

    songs.shuffle();

    queue = songs;
    index = -1;
  }

  Future<void> addToQueue(int songId) async {
    Song? song = await getSong(songId);

    if (song == null) return;

    queue.add(song);
  }
  
  Future<void> restartSong() async { 
    if (currentSong.value == null) return; 
    
    await player.seek(Duration.zero); 
    if (!player.playing) { 
      await player.play(); 
      } 
    }

  void emptyQueue() {
    queue = [];
    currentAlbumCover.value = null;
    currentSong.value = null;
  
  }

}

final audioService = AudioService();