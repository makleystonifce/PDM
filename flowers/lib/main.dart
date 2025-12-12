import 'dart:typed_data';

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
  Uint8List? _photoBytes;

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
                  _photoBytes = bytes;
                  _classificacao = "Processando...";
                });

                // Classificação
                final classifier = Classificadordeflores();
                final List<dynamic> result = await classifier.classify(bytes);

                setState(() {
                  String prop = (result[1] * 100).toStringAsFixed(2) + "%";

                  switch(result[0]){
                    case 0:
                      _classificacao = "Rosas ($prop)";
                      break;
                    case 1:
                      _classificacao = "Tulipas ($prop)";
                      break;
                    case 2:
                      _classificacao = "Margarida ($prop)";
                      break;
                    case 3:
                      _classificacao = "Girassois ($prop)";
                      break;
                    case 4:
                      _classificacao = "Dente De Leão ($prop)";
                      break;
                  }
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

