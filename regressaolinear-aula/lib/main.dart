import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regressão Linear',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Regressão Linear'),
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

  TextEditingController _regressionControler = TextEditingController();

  late Interpreter _interpreter;
  bool _isLoaded = false;
  double? predictResult = 0.0;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/linear_regression.tflite',);
      _isLoaded = true;
      print("Modelo carregado com sucesso!");
    } catch (e) {
      print("Erro ao carregar o modelo: $e");
    }
  }

  Future<double> predict(double inputValue) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      //Shape (1,1) =
      var input = [[inputValue]];
      var output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);
      return output[0][0];
    } catch (e) {
      print('Erro na predição: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:.center,
          children: [
            const Text(
                "Digite um valor como input de uma regressão linear"
            ),
            SizedBox(height: 8,),
            TextField(
              controller: _regressionControler,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
            ),
            SizedBox(height: 8,),
            FilledButton(
                onPressed: () async {
                  final text = _regressionControler.text.trim();
                  final value = double.tryParse(text);
                  if(value == null){
                    print("Valor inválido!");
                  }else{
                    final result = await predict(value);
                    setState(() {
                      predictResult = result;
                      print(predictResult.toString() + " #################");
                    });
                  }
                },
                child: const Text("Estimar valor")),
            SizedBox(height: 8,),
            Card(
              child: Padding(
                padding:  EdgeInsets.all(4),
                child: Text(
                    'O valor predito é: '+predictResult.toString()
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
