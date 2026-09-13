
import 'package:flutter/material.dart';
import 'package:loud_beat/database/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}


class _SongsPageState extends State<SongsPage> {
  
  List<Song> songs = [];

  Future<void> loadSongs() async {
    final loadedSongs = await getSongs();

    setState(() {
      songs = loadedSongs;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSongs();
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
                extentRatio: 0.2,
                motion: const ScrollMotion(), 
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await deleteSong(songs[index]);
                      await loadSongs();
                    },
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.red,
                  )
                ]
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    onTap: () {

                    },
                    title: Text(songs[index].title),
                    leading: const CircleAvatar(
                      child: Icon(Icons.music_note),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      )
    );
  }
}


