import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayVideoScreen extends StatefulWidget {
  final String filePath;
  PlayVideoScreen({Key key, this.filePath}) : super(key: key);

  @override
  _PlayVideoScreenState createState() =>
      _PlayVideoScreenState(filePath: filePath);
}

class _PlayVideoScreenState extends State<PlayVideoScreen> {
  VideoPlayerController _controller;
  final String filePath;

  _PlayVideoScreenState({this.filePath});

  @override
  void initState() {
    super.initState();

    var file = File(filePath ??
        '/data/user/0/com.kelas102.camera_recording/app_flutter/Videos/1574748879375.mp4');
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Play Video"),
      ),
      body: Center(
        child: _controller.value.initialized
            ? Transform.scale(
                scale: _controller.value.aspectRatio / deviceRatio,
                child: new AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: new VideoPlayer(_controller),
                ),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
