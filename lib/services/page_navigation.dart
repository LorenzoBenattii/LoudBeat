import 'package:flutter/material.dart';
import 'package:loud_beat/pages/home_page.dart';
import 'package:loud_beat/pages/settings_page.dart';
import 'package:loud_beat/pages/songs_page.dart';

class PageNavigationService {
  final ValueNotifier<int> selectedPage = ValueNotifier<int>(0);
  final ValueNotifier<bool> refreshSongs = ValueNotifier<bool>(false);
  
  final List pages = [
    HomePage(),
    SongsPage(),
    SettingsPage()
  ];

  void refreshSongsLoaded() {
    refreshSongs.value = !refreshSongs.value;
  }
}

final pageNavigationService = PageNavigationService();