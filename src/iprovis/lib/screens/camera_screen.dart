import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection
import 'product_screen.dart'; // Import ProductPage

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get the list of available cameras
    final cameras = await availableCameras();
    // Use the first camera (usually the rear camera)
    final firstCamera = cameras.first;

    // Initialize the camera controller
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    // Initialize the controller future
    _initializeControllerFuture = _cameraController.initialize();

    // Check if the camera is ready
    _initializeControllerFuture.then((_) {
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Attempt to take a picture
      final image = await _cameraController.takePicture();

      // Handle image path based on platform
      String imagePath;
      if (kIsWeb) {
        // For web, use a placeholder image or upload the image to a server
        imagePath = 'https://via.placeholder.com/150'; // Placeholder image URL
      } else {
        // For mobile, use the file path
        imagePath = image.path;
      }

      // Navigate to the product page with the captured image
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productName: 'Scanned Product',
              productImage: imagePath,
              prices: [
                {'store': 'Store A', 'price': '\$10.00'},
                {'store': 'Store B', 'price': '\$12.00'},
              ],
            ),
          ),
        );
      }
    } catch (e) {
      // If an error occurs, log the error
      print('Error taking photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Product'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview
            return CameraPreview(_cameraController);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isCameraReady ? _takePhoto : null,
        child: Icon(Icons.camera),
      ),
    );
  }
}