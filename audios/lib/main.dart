import 'package:audios/classificador_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classificação de Áudios',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Classificação de Áudios'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String start = "Iniciar captura de áudio";
  String stop = "Parar captura de áudio";

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderReady = false;
  bool _isRecording = false;

  Future<void> initRecorder() async {
    await _recorder.openRecorder();
    _isRecorderReady = true;
    setState(() {});
  }

  Future<void> startRecording() async {
    if (!_isRecorderReady) return;
    await _recorder.startRecorder(
      toFile: 'audio_temp.pcm',
      codec: Codec.pcm16,    // grava PCM cru (sem WAV)
      sampleRate: 16000,     // IGUAL ao Teachable Machine
      numChannels: 1,         // mono
    );
    setState(() {
      _isRecording = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> stopRecording() async {
    if (!_isRecorderReady) return;
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    print("Áudio gravado em: $path");
    ClassificadorAudio _classificadorAudio = ClassificadorAudio();
    _classificadorAudio.classificarAudio(path.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            FilledButton.icon(onPressed: () async {
              if (_isRecording) {
                await stopRecording();
              } else {
                ClassificadorAudio _classificadorAudio = ClassificadorAudio();
                _classificadorAudio.loadModel();
                await startRecording();
              }
            },
              label: Text(_isRecording ? stop : start),
              icon: const Icon(Icons.mic),
            )
          ],
        ),
      ),
    );
  }
}