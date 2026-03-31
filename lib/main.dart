import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'lista_ejercicios.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores generados
  Hive.registerAdapter(SerieAdapter());
  Hive.registerAdapter(EjercicioAdapter());
  
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