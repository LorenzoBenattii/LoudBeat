import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';



import 'package:loud_beat/database/database_helper.dart' as db;
import 'package:loud_beat/services/audio.dart';
import 'package:loud_beat/services/page_navigation.dart';
import 'package:loud_beat/widgets/download_widget.dart';




import 'package:loud_beat/services/user_prompt.dart';
import 'package:loud_beat/services/youtube.dart';
import 'package:youtube_results/youtube_results.dart';

import 'package:loud_beat/pages/playlists_detail_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  
  
  bool isYtReady = false;

  final player = AudioPlayer();
  
  Future<void> initializeYoutubeDL() async {
    try {
      await yt.initializeYoutubeDL();

      if (mounted) {
        setState(() {
          isYtReady = true;
        });
      }

      print("YouTube DL READY");
    } catch (e) {
      print("YouTube DL INITIALIZATION ERROR: $e");
    }
  }

  


  @override
  void initState() {
    super.initState();
    initializeYoutubeDL();
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: pageNavigationService.showPlaylistDetail,
        builder: (context, showDetail, child) {
          if (showDetail) {
            return PlaylistDetailPage(
              playlistId: pageNavigationService.selectedPlaylist.value!,
            );
          }

          return ValueListenableBuilder<int>(
            valueListenable: pageNavigationService.selectedPage,
            builder: (context, selectedPage, child) {
              return pageNavigationService.pages[selectedPage];
            },
          );
        },
      ),

      appBar: AppBar(
        title: const Text("LoudBeat"),

        actions: <Widget>[
          // DOWNLOAD BUTTON
          IconButton(
            onPressed: isYtReady
                ? () async {
                    String title = await userPromptService.askText(context, "Enter Song Name");
                    if (title.isEmpty) return;
                    
                    List<Video>? videos = await yt.youtubeRes.fetchVideos("$title lyrics");
                    
                    if (videos == null || videos.isEmpty) return;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => DownloadWidget(),
                    );

                    String? filePath;
                    Video? selectedVideo;
                    bool isAlreadyDownloaded;
                    
                    for (final video in videos) {
                      if (video.videoId == null) continue;

                      isAlreadyDownloaded = (await db.getSongFromVideoId(video.videoId!) != null); 

                      if (isAlreadyDownloaded) {
                        Navigator.of(context).pop();
                        return;
                      }
                      
                      filePath = await yt.downloadSong(video.videoId!);

                      if (filePath != null) {
                        selectedVideo = video;
                        break;
                      }
                    }

                    if (filePath == null || selectedVideo == null) return;

                    final song = db.Song(
                      title: selectedVideo.title!,
                      length: selectedVideo.duration!,
                      filePath: filePath,
                      videoId: selectedVideo.videoId!,
                    );

                    final insertedSong = await db.insertSong(song);

                    pageNavigationService.refreshSongsLoaded();

                    if (pageNavigationService.showPlaylistDetail.value) {
                      db.Playlist? playlist = await db.getPlaylist(pageNavigationService.selectedPlaylist.value!);
                      await db.addSongToPlaylist(insertedSong, playlist!);
                      pageNavigationService.refreshPlaylistLoaded();
                      
                    }
                    
                  }
                : null,
            icon: const Icon(Icons.download_outlined),
            selectedIcon: const Icon(Icons.download),
          ),

          // SHUFFLE BUTTON
          IconButton(
            onPressed: () async {
              audioService.emptyQueue();
              await audioService.player.stop();

              if (pageNavigationService.showPlaylistDetail.value) {
                await audioService.shuffleQueuePlaylist(pageNavigationService.selectedPlaylist.value!);
                pageNavigationService.closePlaylistDetail();
              }  else {
                await audioService.shuffleQueueAllSongs();
              }
              print("QUEUE LENGTH ${audioService.queue.length}");
              await audioService.playNextSong();

              pageNavigationService.selectedPage.value = 0;

            },
            icon: const Icon(Icons.shuffle_outlined),
            selectedIcon: const Icon(Icons.shuffle),
          ),

          // SEARCH BUTTON
          IconButton(
            onPressed: () async {
              String title = await userPromptService.askText(context, "Enter Song Name");

              if (title.isEmpty) return;

              db.searchSongs(title);

              // TODO: Implement search functionality
            },
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
          ),
        ],
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: pageNavigationService.selectedPage,
        builder: (context, selectedPage, child) {
          return NavigationBar(
            selectedIndex: selectedPage,
            onDestinationSelected: (index) {
              pageNavigationService.selectedPage.value = index;
              pageNavigationService.showPlaylistDetail.value = false;
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: "Songs",
              ),
              NavigationDestination(
                icon: Icon(Icons.playlist_play_outlined),
                selectedIcon: Icon(Icons.playlist_play),
                label: "Playlists",
              ),
            ],
          );
        },
      ),
    );
  }
}


