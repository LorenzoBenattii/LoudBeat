
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loud_beat/database/database_helper.dart';
import 'package:loud_beat/services/user_prompt.dart';

class PlaylistsPage extends StatefulWidget {

  final Function(int) onPlaylistSelected;

  const PlaylistsPage({super.key, required this.onPlaylistSelected});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}


class _PlaylistsPageState extends State<PlaylistsPage> {
  List<Playlist> playlists = [];

  Future<void> loadPlaylists() async {
    final loadedPlaylists = await getPlaylists();

    setState(() {
      playlists = loadedPlaylists;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: ListView.builder(
        itemCount: playlists.length,
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
                      await deletePlaylist(playlists[index]);
                      await loadPlaylists();
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFE63946),
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(12),
                    )
                  ]
                ),
              child: Container(
                decoration: BoxDecoration(
                  
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    onTap: () {
                      widget.onPlaylistSelected(playlists[index].id!);
                    },
                    title: Text(playlists[index].name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500
                    )
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.playlist_play),
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
          final name = await userPromptService.askText(context, "Enter Playlist Name:");

          if (name.isEmpty) return;

          Playlist playlist = Playlist(name: name);

          await insertPlaylist(playlist);
          await loadPlaylists();
        },
        child: const Icon(Icons.add),
      ),



    );
  }
}

