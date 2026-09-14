import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:loud_beat/services/youtube.dart';
import 'dart:io';


class Song {
  final int? id;
  final String title;
  final String length;
  final String? author;
  final String filePath;
  final String videoId;

  Song({this.id, required this.title, required this.length, this.author, required this.filePath, required this.videoId});

  Map<String, Object?> toMap() {
    return {"title": title, "length": length, "author": author, "filePath": filePath, "videoId" : videoId};
  }

  factory Song.fromMap(Map<String, Object?> map) {
    return Song(
      id: map["id"] as int,
      title: map["title"] as String,
      author: map["author"] as String?,
      length: map["length"] as String,
      filePath: map["filePath"] as String,
      videoId: map["videoId"] as String
    );
  }
}


class Playlist {
  final int? id;
  String name;

  Playlist({this.id, required this.name});

  Map<String, Object?> toMap() {
    return {"name": name};
  }

  factory Playlist.fromMap(Map<String, Object?> map) {
    return Playlist(
      id: map["id"] as int,
      name: map["name"] as String
    );
  }
}


Future<Database> getDatabase() async {
  final path = await getDatabasesPath();

  return openDatabase(
    join(path, "database.db"),

    version: 1,

    onConfigure: (db) async {
      await db.execute('PRAGMA foreing_keys = ON');
    },

    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          author TEXT,
          filePath TEXT NOT NULL,
          length TEXT NOT NULL,
          videoId TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE playlists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE playlist_songs (
          playlistId INTEGER NOT NULL,
          songId INTEGER NOT NULL,

          PRIMARY KEY (playlistId, songId),

          FOREIGN KEY (playlistId)
            REFERENCES playlists(id)
            ON DELETE CASCADE,

          FOREIGN KEY (songId)
            REFERENCES songs(id)
            ON DELETE CASCADE
        )
      ''');
    }
  );
}


Future<void> resetDatabase() async {
  final path = await getDatabasesPath();

  await deleteDatabase(join(path, "database.db"));

  final downloadPath = await YoutubeService().getDownloadPath();

  final directory = Directory(downloadPath);

  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }

}



// ---- SONGS  ---- //

Future<int> insertSong(Song song) async {
  final db = await getDatabase();

  return await db.insert(
    "songs",
    song.toMap(),
  );
}


Future<List<Song>> getSongs() async {
  final db = await getDatabase();

  final List<Map<String, Object?>> songMaps = await db.query(
    "songs",
  );

  return [for (final map in songMaps) Song.fromMap(map)];
}


Future<Song?> getSong(int songId) async {
  final db = await getDatabase();

  final List<Map<String, Object?>> songMaps = await db.query(
    "songs",
    where: "id = ?",
    whereArgs: [songId]
  );

  if (songMaps.isEmpty) return null;

  final map = songMaps.first;

  return Song.fromMap(map);
}


Future<void> deleteSong(Song song) async {
  final db = await getDatabase();

  final file = File("${await YoutubeService().getDownloadPath()}/${song.title}.mp3");

  if (await file.exists()) {
    await file.delete();
  }

  final deletedRows = await db.delete(
    'songs',
    where: 'id = ?',
    whereArgs: [song.id],
  );
}



// ---- PLAYLISTS ---- //

Future<int> insertPlaylist(Playlist playlist) async {
  final db = await getDatabase();

  return await db.insert(
    "playlists",
    playlist.toMap()
  );
}


Future<List<Playlist>> getPlaylists() async {
  final db = await getDatabase();

  final List<Map<String, Object?>> playlistMaps = await db.query("playlists");

  return [for (final map in playlistMaps) Playlist.fromMap(map)];
}

Future<Playlist?> getPlaylist(int playlistId) async {
  final db = await getDatabase();

  List<Map<String, Object?>> playlistMaps = await db.query(
    "playlists",
    where: "id = ?",
    whereArgs: [playlistId]
  );

  if (playlistMaps.isEmpty) return null;

  final map = playlistMaps.first;

  return Playlist.fromMap(map);
}

Future<void> updatePlaylistName(Playlist playlist, String newName) async {
  final db = await getDatabase();

  await db.update(
    "playlists",
    {
      "name" : newName,
    },
    where: "id = ?",
    whereArgs: [playlist.id]
  );
}


Future<void> deletePlaylist(Playlist playlist) async {
  final db = await getDatabase();

  await db.delete(
    "playlists",
    where: "id = ?",
    whereArgs: [playlist.id]
  );
}


Future<void> addSongToPlaylist(Song song, Playlist playlist) async {
  final db = await getDatabase();

  await db.insert(
    'playlist_songs',
    {
      'playlistId': playlist.id,
      'songId': song.id,
    },
  );
}

Future<void> deleteSongFromPlaylist(Song song, Playlist playlist) async {
  final db = await getDatabase();

  await db.delete(
    "playlists_songs",
    where: "playlistId = ? AND songId = ?",
    whereArgs: [playlist.id, song.id]
  );
}


Future<List<Song>> searchSongs(String query) async {
  final db = await getDatabase();

  final results = await db.query(
    'songs',
    where: 'title LIKE ?',
    whereArgs: ['%$query%'],
  );

  return results.map((map) => Song.fromMap(map)).toList();
}


