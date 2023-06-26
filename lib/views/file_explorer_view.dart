import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:xmplayer/views/video_player_view.dart';

class FileExplorerView extends StatefulWidget {
  const FileExplorerView({super.key});

  @override
  State<FileExplorerView> createState() => _FileExplorerViewState();
}

class _FileExplorerViewState extends State<FileExplorerView> {
  final FileManagerController _fileManagerController = FileManagerController();

  @override
  void initState() {
    // FileManager.requestFilesAccessPermission();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              _fileManagerController.goToParentDirectory();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: Colors.white,
        title: const Text(
          "File Explorer",
        ),
      ),
      body: FileManager(
        hideHiddenEntity: false,
        controller: _fileManagerController,
        builder: (context, snapshot) {
          final videoPaths = snapshot
              .where((element) =>
                  FileManager.isFile(element) && element.path.contains(".mp4"))
              .toList();

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => ListTile(
              title: Text(
                snapshot[index].absolute.path.split("/").last,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                if (FileManager.isFile(snapshot[index]) &&
                    snapshot[index].path.contains(".mp4")) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerView(
                          currentVideoIndex: videoPaths
                              .map((e) => e.path)
                              .toList()
                              .indexWhere(
                                  (element) => element == snapshot[index].path),
                          paths: videoPaths.map((e) => e.path).toList()),
                    ),
                  );
                } else {
                  _fileManagerController.openDirectory(snapshot[index]);
                }
              },
            ),
            itemCount: snapshot.length,
          );
        },
        loadingScreen: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
