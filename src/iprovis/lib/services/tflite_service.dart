import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter?
  _interpreter; // Nullable yaptık, böylece model yüklenmediğinde kontrol edebilelim diye.
  final int inputSize = 224; // Modelin istediği boyutlandırma
  final int numChannels = 3; // RGB
  final List<String> labels = [
    "Doritos Baharatlı Cips",
    "Pınar Süt",
    "Ülker Çikolatalı Gofret",
  ];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/iprovis_model.tflite');
      print("Model başarıyla yüklendi.");
    } catch (e) {
      print("Model yüklenirken hata: $e");
      rethrow;
    }
  }

  Future<String> predictImage(File imageFile) async {
    if (_interpreter == null) {
      print("Interpreter henüz initialize edilmedi.");
      return "Model yüklenemedi";
    }

    // read image
    final imageBytes = await imageFile.readAsBytes();
    img.Image? oriImage = img.decodeImage(imageBytes);
    if (oriImage == null) {
      return "Görsel okunamadı";
    }

    // Modelin beklediği boyuta getir
    img.Image resizedImage = img.copyResize(
      oriImage,
      width: inputSize,
      height: inputSize,
    );

    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (_) => List.generate(inputSize, (_) => List.filled(numChannels, 0.0)),
      ),
    );

    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        int pixel = resizedImage.getPixel(j, i);
        // normalization
        input[0][i][j][0] = img.getRed(pixel) / 255.0;
        input[0][i][j][1] = img.getGreen(pixel) / 255.0;
        input[0][i][j][2] = img.getBlue(pixel) / 255.0;
      }
    }

    // output tensor
    List<List<double>> output = List.generate(
      1,
      (_) => List.filled(labels.length, 0.0),
    );

    // İnference
    _interpreter!.run(input, output);

    double maxVal = -1;
    int maxIndex = -1;
    for (int i = 0; i < labels.length; i++) {
      if (output[0][i] > maxVal) {
        maxVal = output[0][i];
        maxIndex = i;
      }
    }

    return labels[maxIndex];
  }
}
