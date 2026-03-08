import 'package:flutter/material.dart';
import 'lista_ejercicios.dart';

void main() {
  runApp(const MiAppEntrenamiento());
}

class MiAppEntrenamiento extends StatelessWidget {
  const MiAppEntrenamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue, 
        useMaterial3: true,
      ),
      home: const ListaEjercicios(),
    );
  }
}