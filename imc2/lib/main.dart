import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora IMC'),
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

  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  double _imc = 0.0;
  String _classificacao = "";

  Color _getColor(double imc){
    if(imc < 24.9) return Colors.blue;
    if(imc < 29.9) return Colors.green;
    if(imc < 34.9) return Colors.orange;
    return Colors.red;
  }

  String _getClassificacao(double imc){
    if(imc < 18.5) return "Abaixo do peso normal";
    if(imc < 24.9) return "Peso normal";
    if(imc < 29.9) return "Acima do peso";
    if(imc < 34.9) return "Obesidade Classe I";
    if(imc < 39.9) return "Obesidade Classe II";
    return "Obesidade Classe III";
  }

  void _calcularIMC(){
    double peso = double.parse(_pesoController.text);
    double altura = double.parse(_alturaController.text);
    double resultado = peso / (altura * altura);

    setState(() {
      _imc = resultado;
      _classificacao = _getClassificacao(resultado);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.title, style: TextStyle(color: Colors.white),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _pesoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            label: Text("Peso (kg)"),
                            prefixIcon: Icon(Icons.monitor_weight),
                            border: OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 16,),
                      TextField(
                        controller: _alturaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            label: Text("Altura (m)"),
                            prefixIcon: Icon(Icons.height),
                            border: OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 16,),
                      FilledButton(
                          onPressed: _calcularIMC,
                          child: const Text("Calcular IMC")
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
              if(_imc > 0) Card(
                  child:Padding(
                    padding:EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text("Seu IMC"),
                        SizedBox(height: 8,),
                        Text(_imc.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _getColor(_imc)
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text(_classificacao)
                      ],
                    ),
                  )
              ),
              Spacer(),
              Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "IMC = Peso (kg) ÷ Altura (m)²",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
              )
            ],
          ),
        )
    );
  }
}
