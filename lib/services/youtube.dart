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

    final updateResult = await youtubeDL.updateYoutubeDL(
      channel: UpdateChannel.stable,
    );

    if (updateResult.status == OperationStatus.success) {
      print('yt-dlp updated to: ${updateResult.version}');
    } else {
      print('yt-dlp update failed: ${updateResult.errorMessage}');
    }
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
      outputTemplate: videoId,
      extractAudio: true,
      format: "bestaudio/best",
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

    if (result.status != OperationStatus.success) return null;

    final finalPath = '$downloadPath/$videoId.mp3';

    final file = File(finalPath);

    if (await file.exists()) {
      return finalPath;
    }

    return null;
  }
}


final yt = YoutubeService();