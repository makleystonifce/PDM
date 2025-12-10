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

  // PREPROCESSAMENTO CORRETO: [-1, 1]
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

  Future<int> classify(Uint8List bytes) async {
    await loadModel();

    final image = img.decodeImage(bytes);
    if (image == null) return -1;

    final input = _processImage(image)
        .reshape([1, inputSize, inputSize, 3]);

    final outputTensor = _interpreter.getOutputTensors().first;
    print(outputTensor.toString()+" @@@");
    final numClasses = outputTensor.shape[1];
    print(numClasses.toString()+" ###@@@");

    final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);
    print(output.toString()+" %%%%@@@");

    _interpreter.run(input, output);

    print(output.toString()+" %%%%@@@2222222");

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

    return maxIndex;
  }
}