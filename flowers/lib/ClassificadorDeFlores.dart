import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classificadordeflores {
  late Interpreter _interpreter;
  bool _loaded = false;

  final int inputSize = 224;

  Future<void> loadModel() async {
    if (_loaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/flowers.tflite',
      );
      _loaded = true;
      print("Modelo carregado!");
    } catch (e) {
      print("Erro ao carregar modelo: $e");
    }
  }

  List<List<List<double>>> _processImage(img.Image image) {
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    return List.generate(inputSize, (y) {
      return List.generate(inputSize, (x) {
        final p = resized.getPixel(x, y);

        // Converte para [-1, 1]
        double r = (p.r / 127.5) - 1.0;
        double g = (p.g / 127.5) - 1.0;
        double b = (p.b / 127.5) - 1.0;

        return [r, g, b];
      });
    });
  }

  Future<List<dynamic>> classify(Uint8List bytes) async {
    await loadModel();

    final image = img.decodeImage(bytes);
    if (image == null) return List.empty();

    final input = _processImage(image)
          .reshape([1, inputSize, inputSize, 3]);

    final outputTensor = _interpreter.getOutputTensors().first;
    final numClasses = outputTensor.shape[1];

    final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

    _interpreter.run(input, output);

    // Pega a classe com maior probabilidade
    double maxValue = -999;
    int maxIndex = -1;

    for (int i = 0; i < numClasses; i++) {
      double v = output[0][i];
      print("Classe $i = $v");

      if (v > maxValue) {
        maxValue = v;
        maxIndex = i;
      }
    }

    return [maxIndex, maxValue];
  }
}