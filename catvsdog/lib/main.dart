import 'dart:typed_data';

import 'package:catvsdog/classificador_gato_cachorro.dart';
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
      title: 'Cachorro ou Gato?',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Cachorro ou Gato?'),
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
            style: const TextStyle(color: Colors.white),
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
                final classifier = ClassificadorGatoCachorro();
                final double resultado = await classifier.classificar(bytes);

                setState(() {
                  String res = "";
                  if(resultado >= 0.5) {
                    res = (resultado * 100).toStringAsFixed(2) + "%";
                    _classificacao = "Cachorro ($res)";
                  } else {
                    res = (100 - (resultado * 100)).toStringAsFixed(2)+"%";
                    _classificacao = "Gato ($res)";
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
              "Animal identificado:",
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

