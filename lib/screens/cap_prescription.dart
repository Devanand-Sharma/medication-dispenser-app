import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/widgets/camera_widget.dart';

class CapturePrescriptionScreen extends StatefulWidget {
  static const String routeName = '/cap-prescription';
  const CapturePrescriptionScreen({
    super.key,
    required this.camera,
  });
  final CameraDescription? camera;

  @override
  CapturePrescriptionScreenState createState() =>
      CapturePrescriptionScreenState();
}

class CapturePrescriptionScreenState extends State<CapturePrescriptionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Capture Prescription'),
        ),
        body: CameraWidget(
            camera: widget.camera, snapDestination: '/new-medication'));
  }
}
