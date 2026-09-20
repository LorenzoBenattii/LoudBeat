import 'package:flutter/material.dart';
import 'package:loud_beat/pages/home_page.dart';
import 'package:loud_beat/pages/playlists_detail_page.dart';
import 'package:loud_beat/pages/playlists_page.dart';
import 'package:loud_beat/pages/songs_page.dart';

class PageNavigationService {
  final ValueNotifier<int> selectedPage = ValueNotifier<int>(0);
  final ValueNotifier<bool> refreshSongs = ValueNotifier<bool>(false);

  final ValueNotifier<bool> refreshPlaylist = ValueNotifier<bool>(false);

  final ValueNotifier<int?> selectedPlaylist =
      ValueNotifier<int?>(null);

  final ValueNotifier<bool> showPlaylistDetail =
      ValueNotifier<bool>(false);

  late final List<Widget> pages = [
    HomePage(),
    SongsPage(),
    PlaylistsPage(
      onPlaylistSelected: selectPlaylist,
    ),
  ];

  void selectPlaylist(int playlistId) {
    selectedPlaylist.value = playlistId;
    showPlaylistDetail.value = true;
  }

  void closePlaylistDetail() {
    showPlaylistDetail.value = false;
  }

  void refreshSongsLoaded() {
    refreshSongs.value = !refreshSongs.value;
  }

  void refreshPlaylistLoaded() {
    refreshPlaylist.value = !refreshPlaylist.value;
  }


}
final pageNavigationService = PageNavigationService();