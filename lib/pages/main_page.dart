import 'package:flutter/material.dart';
import 'package:loud_beat/pages/home_page.dart';


import 'package:loud_beat/pages/settings_page.dart';
import 'package:loud_beat/pages/songs_page.dart';
import 'package:loud_beat/database/database_helper.dart';

import 'package:youtube_results/youtube_results.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  int selectedPage = 0;

  final List pages = [
    HomePage(),
    SongsPage(),
    SettingsPage(),
    
  ];
  
  final youtube = YoutubeResults();




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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPage],
      appBar: AppBar(
        title: const Text("LoudBeat"),
        actions: <Widget>[
          IconButton(
            onPressed: () {

            }, 
            icon: Icon(
              Icons.download_outlined
            ),
            selectedIcon: Icon(
              Icons.download
            ),
          ),
          IconButton( //SHUFFLE BUTTON
            onPressed: () {
              //TODO: Add shuffle function
            },
            icon: Icon(
              Icons.shuffle_outlined
            ),
            selectedIcon: Icon(
              Icons.shuffle
            ),
          ),
          IconButton( //SEARCH BUTTON
            onPressed: () async {
              String title = await askText("Enter Song Name");

              List<Video>? videos = await youtube.fetchVideos(title);

              print('''
                title: ${videos?[0].title}
                videoId: ${videos?[0].videoId}
                duration: ${videos?[0].duration}
                viewCount: ${videos?[0].viewCount}
                publishedTime: ${videos?[0].publishedTime}
                channelName: ${videos?[0].channelName}
                channelUrl: ${videos?[0].channelUrl}
                description: ${videos?[0].description}
                thumbnail url: ${videos?[0].thumbnails?[0].url}
                thumbnail height: ${videos?[0].thumbnails?[0].height}
                thumbnail width: ${videos?[0].thumbnails?[0].width}
                videos length : ${videos?.length}''');
              List<Song> test = await searchSongs(title);
              //TODO FINISH THIS
              
            }, 
            icon: Icon(
              Icons.search_outlined
            ),
            selectedIcon: Icon(
              Icons.search
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPage,
        onDestinationSelected: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined
            ),
            selectedIcon: Icon(
              Icons.home
            ),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.library_music_outlined
            ),
            selectedIcon: Icon(
              Icons.library_music_rounded
            ),
            label: "Songs",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined
            ),
            selectedIcon: Icon(
              Icons.settings
            ),
            label: "Settings",
          ),
        ],
      ),

    );
  }
}


