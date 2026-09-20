

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loud_beat/database/database_helper.dart';
import 'package:loud_beat/services/audio.dart';
import 'package:loud_beat/services/page_navigation.dart';
import 'package:loud_beat/services/user_prompt.dart';
import 'package:loud_beat/widgets/similar_songs_widget.dart';

class PlaylistDetailPage extends StatefulWidget {
  final int playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  State<StatefulWidget> createState() => _PlaylistDetailPageState();
}


class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<Song> songs = [];
  Playlist? playlist = null;


  Future<void> loadSongs() async {
    final loadedPlaylist = await getPlaylist(widget.playlistId);
    final loadedSongs = await getSongsFromPlaylist(loadedPlaylist!);

    setState(() {
      songs = loadedSongs;
      playlist = loadedPlaylist;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSongs();
    pageNavigationService.refreshPlaylist.addListener(loadSongs);
  
  }

  @override
  void dispose() {
    pageNavigationService.refreshPlaylist.removeListener(loadSongs);
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(), 
                extentRatio: 0.2,
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await deleteSongFromPlaylist(songs[index], playlist!);
                      await loadSongs();
                    },
                    backgroundColor: const Color(0xFFE63946),
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(12),
                  )
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    onTap: () async {
  print("1 - SONG PRESSED");
  
  audioService.emptyQueue();

  print("2 - BEFORE CREATE QUEUE");

  await audioService.createQueueFromSongPlaylist(
    songs[index].id!,
    pageNavigationService.selectedPlaylist.value!,
  );

  print("3 - AFTER CREATE QUEUE");

  for (Song song in audioService.queue) {
    print("SONG: ${song.title}");
  }

  print("4 - BEFORE PLAY");
  
  audioService.playNextSong();

  print("5 - AFTER PLAY");
},
                    title: Text(songs[index].title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500
                      ),
                    ),
                    leading: const CircleAvatar(
                      child: Icon(Icons.music_note),
                    ),
                  ),
                ),
              ),
            ),
          );
        } 
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          
          final title = await userPromptService.askText(context, "Enter Song Name:");

          final Song? chosenSong = await showModalBottomSheet(
            context: context, 
            builder: (context) => SimilarSongsWidget(
              title: title, 
              onSongSelected: (song) {
                Navigator.pop(context, song);
              }
            ),
          );

          if (chosenSong == null) return;

          await addSongToPlaylist(chosenSong, playlist!);
          await loadSongs();


        },
        child: const Icon(Icons.add), 
      )

    );
  }

}

