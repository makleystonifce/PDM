import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flowers/ClassificadorDeFlores.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowers',
      theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
    ),
    home: const MyHomePage(title: 'Flowers'),
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
  String _classificacao = "";
  XFile? _photo;
  Uint8List? _photoBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Área da imagem
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400),
              ),
              clipBehavior: Clip.hardEdge,
              child: _photoBytes == null
                  ? Center(
                child: Text(
                  "Nenhuma imagem capturada",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
                  : Image.memory(
                _photoBytes!,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();

                final XFile? photo = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 224,
                  maxHeight: 224,
                );

                if (photo == null) return;

                final bytes = await photo.readAsBytes();

                setState(() {
                  _photo = photo;
                  _photoBytes = bytes;
                  _classificacao = "Processando...";
                });

                // Classificação
                final classifier = Classificadordeflores();
                final int classId = await classifier.classify(bytes);

                setState(() {
                  switch(classId){
                    case 0:
                      _classificacao = "Rosas";
                      break;
                    case 1:
                      _classificacao = "Tulipas";
                      break;
                    case 2:
                      _classificacao = "Margarida";
                      break;
                    case 3:
                      _classificacao = "Girassois";
                      break;
                    case 4:
                      _classificacao = "DenteDeLeao";
                      break;
                  }
                  // _classificacao = classId.toString();
                });
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tirar Foto"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Flor identificada:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _classificacao.isEmpty ? "---" : _classificacao,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

