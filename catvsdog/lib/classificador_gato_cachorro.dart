import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificadorGatoCachorro {

  late Interpreter _interpreter;
  bool _loaded = false;

  final inputSize = 224;

  Future<void> carregarModelo() async {
    if (_loaded) return;

    try {
      _interpreter =
      await Interpreter.fromAsset('assets/models/catvsdog.tflite');
      _loaded = true;
      print("Modelo carregado com sucesso!");
    } catch (e) {
      print("Falha ao carregar modelo! Erro: " + e.toString());
      _loaded = false;
    }
  }

  List<List<List<double>>> _processarImagem(img.Image image) {
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

  Future<double> classificar(Uint8List imageBytes) async {
    if (!_loaded) {
      await carregarModelo();
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Falha ao decodificar imagem!");
    }

    final input = _processarImagem(image).reshape([1, inputSize, inputSize, 3]);

    final outputTensor = _interpreter.getOutputTensors().first;
    print("Output: "+outputTensor.toString());

    final outputNumClasses = outputTensor.shape[1];
    final output = List.filled(outputNumClasses, 0.0).reshape([1, outputNumClasses]);

    _interpreter.run(input, output);
    print("Resultado: "+output.toString());

    return output[0][0];
    // if(output[0][0] >= 0.5 ) return 0; //Cachorro
    // else return 1; //Gato
  }

}