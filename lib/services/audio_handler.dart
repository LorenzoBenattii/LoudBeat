import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loud_beat/services/audio.dart';

class AudioHandlerService extends BaseAudioHandler
    with QueueHandler, SeekHandler {

  final AudioPlayer _player = audioService.player;

  AudioHandlerService() {
    _player.playbackEventStream.listen(_broadcastState);

    audioService.currentSong.addListener(_updateCurrentSong);
  }

  void _updateCurrentSong() {
    final song = audioService.currentSong.value;

    if (song == null) return;

    mediaItem.add(
      MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.author,
        duration: _player.duration,
      ),
    );
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: [
          if (_player.playing)
            MediaControl.pause
          else
            MediaControl.play,
          MediaControl.skipToPrevious,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(
          _player.processingState,
        ),
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(
    ProcessingState state,
  ) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> skipToNext() {
    return audioService.playNextSong();
  }

  @override
  Future<void> skipToPrevious() {
    return audioService.goToPreviousSong();
  }
}