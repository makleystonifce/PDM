import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificadorAudio {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/audio.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print("Erro ao carregar o modelo: $e");
    }
  }

  Future<List<double>> classificarAudio(String audioPath) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    print("%%%%%%%%%%%%%%%%%%%%%");
    print(_interpreter.getInputTensor(0).shape);
    print(_interpreter.getOutputTensor(0).shape);

    final file = File(audioPath);
    final pcmBytes = await file.readAsBytes();

    final byteData = ByteData.sublistView(pcmBytes);
    final numSamples = pcmBytes.length ~/ 2;

    final Float32List floatBuffer = Float32List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little);
      floatBuffer[i] = sample / 32768.0; // Tamnho do int16: -32768 ~ +32767
    }

    const tamanhoEsperado = 44032;
    Float32List inputBuffer = Float32List(tamanhoEsperado);

    for (int i = 0; i < tamanhoEsperado; i++) {
      inputBuffer[i] = i < numSamples ? floatBuffer[i] : 0.0;
    }

    final input = inputBuffer.reshape([1, tamanhoEsperado]);
    final output = List.filled(3, 0.0).reshape([1, 3]);

    _interpreter.run(input, output);
    print(output[0]);
    return output[0];

  }
}
