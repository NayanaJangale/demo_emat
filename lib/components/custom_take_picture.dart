import 'dart:io';

import 'package:camera/camera.dart';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CustomTakePicture extends StatefulWidget {
  final CameraDescription camera;

  const CustomTakePicture({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _CustomTakePictureState createState() => _CustomTakePictureState();
}

class _CustomTakePictureState extends State<CustomTakePicture> {

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        gradient: LinearGradient(
            colors: [Colors.green[500], Colors.lightBlueAccent]),
        title: CustomAppBar(
          title: "Hi "+ AppData.current.user.UserName,
          subtitle: "Let's take a Selfie",
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            await _controller.takePicture(path);
            Navigator.pop(context, path);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }

}
