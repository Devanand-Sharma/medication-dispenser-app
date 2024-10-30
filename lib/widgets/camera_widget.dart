import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/utils/barcode_extract.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:medication_app/models/medication.dart';
import 'package:medication_app/models/medication_route.dart';
import 'package:medication_app/models/medication_frequency.dart';

import 'package:medication_app/screens/medication_form.dart';

class CameraWidget extends StatefulWidget {
  final CameraDescription? camera;
  final String snapDestination;
  const CameraWidget({
    super.key,
    required this.camera,
    required this.snapDestination,
  });

  @override
  State<StatefulWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();

    if (widget.camera == null) {
      _controller = null;
    } else {
      _controller = CameraController(
        widget.camera!,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _textRecognizer.close();
      _barcodeScanner.close();
      _controller!.dispose();
    }
    super.dispose();
  }

  Future<String?> _processBarcode(InputImage inputImage) async {
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (barcodes.length != 1) {
      return null;
    }
    return barcodes[0].rawValue;
  }

  Future<String?> _processText(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<void> capturePrescription(BuildContext context) async {
    try {
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      String? medName;
      String? cond;
      MedicationRoute? route;
      int? dose;
      int? totalQuantity;
      MedicationFrequency? frequency;
      int? frequencyCount;

      final processedBarcode = await _processBarcode(inputImage);
      if (processedBarcode != null && processedBarcode.length >= 10) {
        // String ndc = processedBarcode.substring(0, 10);
        // TODO: send ndc to backend and get medication name
        print(
            'capturePrescription(): Valid barcode scanned. Extract ndc and send to backend for lookup');
      } else {
        print(
            'capturePrescription(): Invalid barcode scanned. Either too many barcodes (FIXME) or invalid barcode');
      }

      final processedText = await _processText(inputImage);
      if (processedText != null && processedText.isNotEmpty) {
        route = determineMedicineRoute(processedText);
        totalQuantity = determineTotalQuantity(processedText);
        dose = determineMedicineDose(processedText);
        frequency = determineMedicineFrequency(processedText);
        frequencyCount = determineMedicineFrequencyCount(processedText);
      }

      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationFormScreen(
              medication: Medication(
                id: 0,
                name: medName ?? "",
                condition: cond ?? "",
                route: route ?? MedicationRoute.tablet,
                dose: dose ?? 0,
                totalQuantity: totalQuantity ?? 0,
                remainingQuantity: totalQuantity ?? 0,
                thresholdQuantity: totalQuantity != null ? (totalQuantity * 0.1).ceil() : 0,
                isRefillReminder: true,
                frequency: frequency ?? MedicationFrequency.onceADay,
                frequencyCount: frequencyCount ?? 0,
                startDate: DateTime.now(),
                isReminder: true,
                instructions: "",
                scheduledTimes: List.empty(), // TODO: potentially parse from label?
                administeredTimes: List.empty(),
                refillDates: List.empty(),
              ),
              isEditing: false,
            ),
          ),
        );
      }
    } catch (e) {
      print('capturePrescription(): Exception $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.camera == null) {
      return const NoCameraWidget();
    }
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller!);
            }
            // waiting icon for camera to load
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => capturePrescription(context),
          child: Icon(
              color: Theme.of(context).colorScheme.inverseSurface,
              Icons.camera)),
    );
  }
}

class NoCameraWidget extends StatelessWidget {
  const NoCameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('NO ACCESSIBLE CAMERA'),
    ));
  }
}
