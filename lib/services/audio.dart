import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();

  Future<void> dispose() async {
    await player.dispose();
  }
}


final audioService = AudioService();