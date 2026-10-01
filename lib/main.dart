import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:loud_beat/services/audio_handler.dart';
import 'pages/main_page.dart';
import 'package:loud_beat/database/database_helper.dart';

late AudioHandler _audioHandler;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  _audioHandler = await AudioService.init(
    builder: () => AudioHandlerService(),
    config: AudioServiceConfig(
      androidNotificationChannelId: "com.example.loud_beat.channel.audio",
      androidNotificationChannelName: "Music playback"
    )
  );
  
  
  //resetDatabase();
  
  
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoudBeat',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF5F5DC), // Beige
        colorScheme: ColorScheme.light(
          primary: Color(0xFFFF4500),      // Orange Red - main actions
          secondary: Color(0xFF2E8B57),    // Sea Green - secondary actions
          tertiary: Color(0xFFFFD700),     // Gold - highlights/selected states
          surface: Color(0xFFF5F5DC),      // Beige - cards
          onSurface: Color(0xFF4B0082),    // Indigo - text on cards
          onPrimary: Colors.white,         // text/icons on Orange Red buttons
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4B0082), // Indigo
          foregroundColor: Color(0xFFF5F5DC), // Beige text/icons
          elevation: 2,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Color(0xFF4B0082)),   // song titles
          bodyMedium: TextStyle(color: Color(0xFF4B0082)),   // body text
        ),
        iconTheme: IconThemeData(color: Color(0xFF4B0082)),
        fontFamily: "Orbitron"
      ),
      home: const MainPage(),
    );
  }
}




