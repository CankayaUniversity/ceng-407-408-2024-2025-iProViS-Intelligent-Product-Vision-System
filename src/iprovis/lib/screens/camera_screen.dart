import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart'; // Galeri için gerekli paket
import 'dart:io';
import 'product_screen.dart'; // Ürün sayfası
import 'package:iprovis/services/tflite_service.dart'; // tflite_service.dart dosyasının yolu

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
  final ImagePicker _imagePicker = ImagePicker(); // ImagePicker örneği

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

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Modeli çalıştırarak tahmin al
        String predictedLabel = await _tfliteService.predictImage(imageFile);

        // Tahmin sonucuna göre ürünü göster
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productName: predictedLabel,
                productImage: pickedFile.path,
                prices: [],
              ),
            ),
          );
        }
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

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      await _modelLoadedFuture;

      final image = await _cameraController.takePicture();
      String imagePath;
      if (kIsWeb) {
        imagePath = 'https://via.placeholder.com/150';
      } else {
        imagePath = image.path;
      }

      String predictedLabel = "Bilinmiyor";
      if (!kIsWeb) {
        File imageFile = File(imagePath);
        predictedLabel = await _tfliteService.predictImage(imageFile);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productName: predictedLabel,
              productImage: imagePath,
              prices: [],
            ),
          ),
        );
      }
    } catch (e) {
      print('Fotoğraf çekilirken hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Product')),
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
            child: Icon(Icons.camera),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _pickImageFromGallery,
            child: Icon(Icons.photo),
          ),
        ],
      ),
    );
  }
}
