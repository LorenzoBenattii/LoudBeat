import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';

import 'package:loud_beat/widgets/download_widget.dart';
import 'package:loud_beat/database/database_helper.dart';


class SimilarSongsWidget extends StatefulWidget {

  final String title;
  final Function(Song) onSongSelected;

  const SimilarSongsWidget({super.key, required this.title, required this.onSongSelected});
  
  @override
  State<SimilarSongsWidget> createState() => _SimilarSongsWidgetState(); 
}


class _SimilarSongsWidgetState extends State<SimilarSongsWidget> {
  List<Song> songs = [];

  Future<void> loadSongs() async {
    final loadedSongs = await searchSongs(widget.title);

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16,),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  child: Slidable(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          onTap: () {
                            widget.onSongSelected(songs[index]);
                          },
                          title: Text(songs[index].title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ))
        ]
      ),
    );
  }


}


