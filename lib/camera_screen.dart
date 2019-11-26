import 'dart:io';

import 'package:camera_recording/play_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras;
  CameraController controller;
  String videoPath = "";

  _loadCameras() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      print("Camera 0 : ${cameras[0]}");
      cameras.forEach((f) {
        print("Camera 1 : ${f.name}");
      });

      _onCameraSwitched(cameras[0]);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    if (controller?.value == null) {
      return Container(
        child: Text("Please wait...."),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Transform.scale(
          scale: controller.value.aspectRatio / deviceRatio,
          child: new AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black12,
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.flash_auto,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  iconSize: 72,
                  icon: Icon(
                    Icons.fiber_manual_record,
                    color: controller.value.isInitialized &&
                            !controller.value.isRecordingVideo
                        ? Colors.white
                        : Colors.red,
                  ),
                  onPressed: controller.value.isInitialized &&
                          !controller.value.isRecordingVideo
                      ? _onStartVideoRecording
                      : _onStopVideoRecording,
                ),
                IconButton(
                  icon: Icon(
                    Icons.camera_rear,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.ondemand_video,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayVideoScreen(
                          filePath: videoPath,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller?.value != null) {
      await controller.dispose();
    }

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  /// Switch front & back camera if supported
  void _onSwitchCamera() {
    ///gunakan camera description untuk berpindah camera
  }

  /// Record video
  void _onRecordButtonPressed() {}

  /// Record video
  Future<String> _onStartVideoRecording() async {
    if (!controller.value.isInitialized) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Please wait...."),
      ));
      return null;
    }

    /// Video recording process
    if (controller.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/${currentTime}.mp4';

    try {
      await controller.startVideoRecording(filePath);
      setState(() {
        videoPath = filePath;
        print("PATH: $videoPath");
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  /// Video recording stoped
  Future<void> _onStopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
      setState(() {});
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  /// Camera Exception
  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Error: ${e.code}\n${e.description}'),
    ));
  }
}
