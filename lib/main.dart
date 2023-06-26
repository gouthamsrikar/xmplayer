import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:xmplayer/views/file_explorer_view.dart';
import 'package:xmplayer/views/video_player_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FileManager.requestFilesAccessPermission();
  await Permission.storage.request();
  await Permission.videos.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white, size: 48),
        ),
        home: FileExplorerView()

        //  const VideoPlayerView(
        //   key: Key("video_player_view"),
        // ),
        );
  }
}
