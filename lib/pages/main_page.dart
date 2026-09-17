import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loud_beat/pages/home_page.dart';
import 'package:extractor/extractor.dart';

import 'package:loud_beat/pages/settings_page.dart';
import 'package:loud_beat/pages/songs_page.dart';
import 'package:loud_beat/database/database_helper.dart';
import 'package:loud_beat/services/audio.dart';
import 'package:loud_beat/services/page_navigation.dart';
import 'package:loud_beat/widgets/download_widget.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';



import 'package:loud_beat/services/youtube.dart';
import 'package:youtube_results/youtube_results.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  
  
  bool isYtReady = false;

  final player = AudioPlayer();
  


  Future<String> askText(String text) async {
    final controller = TextEditingController();

    final result = await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              }, 
              child: const Text("OK"))
          ],
        );
      }
    );
      
    return result ?? "";
  }


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
      body: ValueListenableBuilder<int>(
        valueListenable: pageNavigationService.selectedPage,
        builder: (context, selectedPage, child) {
          return pageNavigationService.pages[selectedPage];
        },
      ),

      appBar: AppBar(
        title: const Text("LoudBeat"),

        actions: <Widget>[
          // DOWNLOAD BUTTON
          IconButton(
            onPressed: isYtReady
                ? () async {
                    String title = await askText("Enter Song Name");
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

                    
                    for (final video in videos) {
                      if (video.videoId == null) continue;

                      filePath = await yt.downloadSong(video.videoId!);

                      if (filePath != null) {
                        selectedVideo = video;
                        break;
                      }
                    }

                    if (filePath == null || selectedVideo == null) return;

                    final song = Song(
                      title: selectedVideo.title!,
                      length: selectedVideo.duration!,
                      filePath: filePath,
                      videoId: selectedVideo.videoId!,
                    );

                    await insertSong(song);

                    pageNavigationService.refreshSongsLoaded();
                    
                  }
                : null,
            icon: const Icon(Icons.download_outlined),
            selectedIcon: const Icon(Icons.download),
          ),

          // SHUFFLE BUTTON
          IconButton(
            onPressed: () async {
              audioService.emptyQueue();
              await audioService.shuffleQueue();
              audioService.playNextSong();

              pageNavigationService.selectedPage.value = 0;
            },
            icon: const Icon(Icons.shuffle_outlined),
            selectedIcon: const Icon(Icons.shuffle),
          ),

          // SEARCH BUTTON
          IconButton(
            onPressed: () async {
              String title = await askText("Enter Song Name");

              if (title.isEmpty) return;

              searchSongs(title);

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
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          );
        },
      ),
    );
  }
}


