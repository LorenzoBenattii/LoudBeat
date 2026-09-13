import 'dart:io';

import 'package:extractor/extractor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_results/youtube_results.dart';

class YoutubeService {
  final youtubeDL = YoutubeDLFlutter.instance;
  final youtubeRes = YoutubeResults();

  bool _initialized = false;

  Future<void> initializeYoutubeDL() async {
    final result = await youtubeDL.initialize(
      enableFFmpeg: true,
      enableAria2c: false,
    );

    if (!result.success) {
      throw Exception(
        'YouTube DL initialization failed: ${result.errorMessage}',
      );
    }

    _initialized = true;
    print('YouTube DL initialized successfully');
  }

  Future<String> getDownloadPath() async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final downloadDirectory = Directory(
      '${appDirectory.path}/LoudBeat/Downloads',
    );

    if (!await downloadDirectory.exists()) {
      await downloadDirectory.create(recursive: true);
    }

    return downloadDirectory.path;
  }

  Future<String?> downloadSong(String videoId) async {
    if (!_initialized) {
      throw Exception('YoutubeDL is not initialized');
    }

    final downloadPath = await getDownloadPath();

    print('DOWNLOAD PATH: $downloadPath');

    final request = DownloadRequest(
      url: 'https://www.youtube.com/watch?v=$videoId',
      outputPath: downloadPath,
      outputTemplate: '%(title)s.%(ext)s',
      extractAudio: true,
      audioFormat: 'mp3',
      audioQuality: 0,
      embedThumbnail: true,
      embedMetadata: true,
      processId: 'audio_${DateTime.now().millisecondsSinceEpoch}',
    );

    final result = await youtubeDL.download(request);

    print('STATUS: ${result.status}');
    print('OUTPUT PATH: ${result.outputPath}');
    print('ERROR: ${result.errorMessage}');


    return result.errorMessage == null ? result.outputPath : null;
  }
}