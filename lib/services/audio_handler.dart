
import 'package:audio_service/audio_service.dart';
import 'package:loud_beat/services/audio.dart';

class AudioHandlerService extends BaseAudioHandler
  with QueueHandler,
  SeekHandler {
    final _player = audioService.player;

    Future<void> play() => _player.play();
    Future<void> pause() => _player.pause();
    Future<void> stop() => _player.stop();
    Future<void> seek(Duration position) => _player.seek(position);
    Future<void> skipToQueueItem(int i) => _player.seek(Duration.zero, index: i);



  }

