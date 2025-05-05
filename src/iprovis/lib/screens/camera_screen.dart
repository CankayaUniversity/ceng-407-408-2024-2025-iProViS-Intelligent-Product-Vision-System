import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:iprovis/services/tflite_service.dart';
import 'package:iprovis/screens/product_info_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late Future<void> _modelLoadedFuture;
  bool _isCameraReady = false;
  final TFLiteService _tfliteService = TFLiteService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _modelLoadedFuture = _tfliteService.loadModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);

    _initializeControllerFuture = _cameraController.initialize();
    _initializeControllerFuture.then((_) {
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });
    });
  }

  Future<void> _processImage(String imagePath) async {
    String predictedLabel = await _tfliteService.predictImage(File(imagePath));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProductInfoScreen(
                keyword: predictedLabel,
                imagePath: imagePath,
              ),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      await _processImage(image.path);
    } catch (e) {
      print('Fotoğraf çekilirken hata oluştu: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        await _processImage(pickedFile.path);
      }
    } catch (e) {
      print('Galeriden fotoğraf seçilirken hata oluştu: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('scan_product'.tr())),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _isCameraReady ? _takePhoto : null,
            tooltip: 'take_photo'.tr(),
            child: Icon(Icons.camera),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _pickImageFromGallery,
            tooltip: 'select_from_gallery'.tr(),
            child: Icon(Icons.photo),
          ),
        ],
      ),
    );
  }
}
