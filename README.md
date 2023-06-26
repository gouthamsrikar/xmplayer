# xmplayer

Flutter video player project.
##  Getting Started with Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### To install all the dependencies
```bash
flutter pub get
```

### To run the app
```bash
flutter run
```

if SDK version is not matching try changing it in `pubspec.yaml` or try upgrading the SDK to the latest stable version

## APP flow 

file explorer screen --> navigate through the folders --> tap on the videos

currently I haven't given support for other format videos to play other than mp4

## Folder structure and files

| **File Name** | **path**                                        | 
| :------------- | :----------------------------------------------------------- |
| file_explorer_view.dart  | `contain the basic directory navigation` |
| video_player_view.dart  | `contains all the video player logic` | 

## Important Code Snippets explaination

### video initialzation 

```dart
@override
  void initState() {
    super.initState();

    index = widget.currentVideoIndex;
    _videocontroller = VideoPlayerController.file(
      File(widget.paths[index]),
    )..initialize().then((_) {
        setState(() {});
        _videocontroller.addListener(
          () {
            _videoPositionListener();
          },
        );
        _videocontroller.play();
        _videocontroller.setLooping(isLoop);
      }, onError: (_) {});
  }

```

### video play and pause during app lifecycle when video is open

```dart
@override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed');
        _videocontroller.play();

        break;
      case AppLifecycleState.inactive:
        print('inactive');

        _videocontroller.pause();

        break;
      case AppLifecycleState.paused:
        print('paused');
        _videocontroller.pause();

        break;
      case AppLifecycleState.detached:
        _videocontroller.dispose();
        _positionStreamController.close();

        break;
    }
  }
```

### converting position data into a stream while listening to the videocontroller

```dart
 void _videoPositionListener() {
    if (_videocontroller.value.isPlaying) {
      _positionStreamController.add(_videocontroller.value.position);
    }
    if (_videocontroller.value.position == _videocontroller.value.duration &&
        !isLoop) {
      // _positionStreamController.add(Duration.zero);
      playNext();
    }
  }
```

### progress bar widget

```dart
 Widget videoProgressBar() {
    return StreamBuilder<Duration>(
      stream: _positionStreamController.stream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return progress_bar.ProgressBar(
          progressBarColor: Colors.red,
          baseBarColor: Colors.grey,
          bufferedBarColor: Colors.white,
          thumbColor: Colors.red,
          barHeight: 3.0,
          thumbRadius: 7.0,
          progress: positionData ?? Duration.zero,
          buffered: positionData ?? Duration.zero,
          total: _videocontroller.value.duration ?? Duration.zero,
          // onDragUpdate: (details) async {
          //   await _videocontroller.seekTo(details.timeStamp).then((value) {
          //     _videocontroller.play();
          //   });
          // },
          onSeek: (duration) async {
            await _videocontroller.seekTo(duration).then((value) {
              _videocontroller.play();
            });
          },
        );
      },
    );
  }
```




