import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  late List<String> _labels;
  final int inputSize = 224;
  final int numChannels = 3;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/iprovis_model_v4.tflite',
      );
      print("Model başarıyla yüklendi.");

      final rawLabels = await rootBundle.loadString('assets/labels.txt');
      _labels =
          rawLabels
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      print("${_labels.length} adet etiket yüklendi.");
    } catch (e) {
      print("loadModel() sırasında hata: $e");
      rethrow;
    }
  }

  /// Fotoğrafı modele gönderip tahmin yapar
  Future<String> predictImage(File imageFile) async {
    if (_interpreter == null) return "Model yüklenemedi";

    // Görseli oku ve ön işle
    final bytes = await imageFile.readAsBytes();
    img.Image? oriImage = img.decodeImage(bytes);
    if (oriImage == null) return "Görsel okunamadı";
    img.Image resized = img.copyResize(
      oriImage,
      width: inputSize,
      height: inputSize,
    );

    // Input tensor
    var input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (_) => List.generate(inputSize, (_) => List.filled(numChannels, 0.0)),
      ),
    );
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        int p = resized.getPixel(j, i);
        input[0][i][j][0] = img.getRed(p) / 255.0;
        input[0][i][j][1] = img.getGreen(p) / 255.0;
        input[0][i][j][2] = img.getBlue(p) / 255.0;
      }
    }

    // Output tensor
    var output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    // İnference
    _interpreter!.run(input, output);

    // En yüksek olasılığa sahip etiketi bul
    int maxIndex = 0;
    double maxVal = output[0][0];
    for (int i = 1; i < _labels.length; i++) {
      if (output[0][i] > maxVal) {
        maxVal = output[0][i];
        maxIndex = i;
      }
    }

    return _labels[maxIndex];
  }
}
