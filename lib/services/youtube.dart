import 'dart:io';

import 'package:extractor/extractor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_results/youtube_results.dart' as res;
import 'package:flutter/foundation.dart';

class YoutubeService {
  final youtubeDL = YoutubeDLFlutter.instance;
  final youtubeRes = res.YoutubeResults();
  
  
  final activeDownloads = {};
  final downloadProgress = {};
  final downloadState = {};
  final downloadError = {};

  bool _initialized = false;

  VoidCallback? onDownloadsChanged;


  void listenToProgress() {
    youtubeDL.onProgress.listen((progress) {
      if (progress.progress >= 0) {
        downloadProgress[progress.processId] = progress.progress;
      }

      onDownloadsChanged?.call();
    });
  }

  void listenToStateChange() {
    youtubeDL.onStateChanged.listen((state) {
      downloadState[state.processId] = state.state;
      onDownloadsChanged?.call();
    });
  }

  void listenToError() {
    youtubeDL.onError.listen((error) {
      downloadError[error.processId] = error.error;
      onDownloadsChanged?.call();
    });
  }


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


    listenToProgress();
    listenToError();
    listenToStateChange();
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

    res.VideoInfo? videoInfo = await youtubeRes.fetchVideoInfo(videoId);

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

    activeDownloads[request.processId] = videoInfo!.title;
    downloadProgress[request.processId] = 0.0;
    downloadState[request.processId] = 'Starting...';

    final result = await youtubeDL.download(request);

    activeDownloads.remove(request.processId);
    downloadProgress.remove(request.processId);
    downloadState.remove(request.processId);
    downloadError.remove(request.processId);

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