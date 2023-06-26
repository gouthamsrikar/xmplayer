import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
import 'package:xmplayer/views/video_view.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'
    as progress_bar;

bool isLoop = false;

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView(
      {super.key, required this.paths, required this.currentVideoIndex});

  final List<String> paths;
  final int currentVideoIndex;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView>
    with WidgetsBindingObserver {
  late int index;
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

  @override
  void dispose() {
    _videocontroller.dispose();
    _positionStreamController.close();
    super.dispose();
  }

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

  void playNext() async {
    if (index < widget.paths.length - 1) {
      index++;
      _videocontroller.dispose();
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
        }, onError: (_) {});
    } else {
      Navigator.pop(context);
    }
  }

  void playPrevious() {
    if (index > 0) {
      index--;
      _videocontroller.dispose();
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
        }, onError: (_) {});
    }
  }

  late VideoPlayerController _videocontroller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(context),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Stack(
          children: [
            Center(
              child: VideoView(
                _videocontroller,
                MediaQuery.of(context).size.width * (9 / 16),
              ),
            ),
            // _appBar(context),
            Row(
              children: [
                InkWell(
                  onDoubleTap: () {
                    _videocontroller
                        .seekTo(_videocontroller.value.position -
                            const Duration(seconds: 10))
                        .then((value) => _videocontroller.play());
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ),
                InkWell(
                  onDoubleTap: () {
                    _videocontroller
                        .seekTo(_videocontroller.value.position +
                            const Duration(seconds: 10))
                        .then((value) => _videocontroller.play());
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Opacity(
                opacity: 0.5,
                child: _playerButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  final StreamController<Duration> _positionStreamController =
      StreamController();

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

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
      title: Text(
        widget.paths[index].split("/").last,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              isLoop = !isLoop;
              _videocontroller.setLooping(isLoop);
            });
          },
          icon: isLoop
              ? const Icon(
                  Icons.sync_sharp,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.sync_disabled_outlined,
                  color: Colors.white,
                ),
        )
      ],
    );
  }

  Widget _playerButtons() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: videoProgressBar(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  playPrevious();
                },
                icon: const Icon(Icons.skip_previous_sharp),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _videocontroller.value.isPlaying
                        ? _videocontroller.pause()
                        : _videocontroller.play();
                  });
                },
                icon: _videocontroller.value.isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {
                  playNext();
                },
                icon: const Icon(Icons.skip_next_sharp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
