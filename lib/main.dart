import 'package:flutter/material.dart';
import 'models.dart';
import 'detalle_ejercicio.dart';

void main() {
  runApp(const MiAppEntrenamiento());
}

class MiAppEntrenamiento extends StatelessWidget {
  const MiAppEntrenamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ListaEjercicios(),
    );
  }
}

class ListaEjercicios extends StatefulWidget {
  const ListaEjercicios({super.key});

  @override
  State<ListaEjercicios> createState() => _ListaEjerciciosState();
}

class _ListaEjerciciosState extends State<ListaEjercicios> {
  // Asegúrate de que en models.dart el constructor de Ejercicio pida la imagen
  Map<String, Ejercicio> diario = {
    'Bench Press': Ejercicio('Bench Press', 'assets/bench.png', []),
    'Squat': Ejercicio('Squat', 'assets/squat.png', []),
    'Deadlift': Ejercicio('Deadlift', 'assets/deadlift.png', []),
    'Overhead Press': Ejercicio('Overhead Press', 'assets/overhead.png', []),
  };

  @override
  Widget build(BuildContext context) {
    final ejerciciosVisibles = diario.values.where((e) => e.series.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso'), centerTitle: true),
      body: ListView.builder(
        itemCount: ejerciciosVisibles.length + 1,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          if (index < ejerciciosVisibles.length) {
            final eje = ejerciciosVisibles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    eje.imagePath,
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center, size: 40),
                  ),
                ),
                title: Text(eje.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${eje.series.length} series completadas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _irADetalle(eje.nombre),
              ),
            );
          } else {
            return _botonAgregar();
          }
        },
      ),
    );
  }

  Widget _botonAgregar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _mostrarSelector,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('AGREGAR EJERCICIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  void _irADetalle(String nombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEjercicio(
          ejercicio: diario[nombre]!,
          onActualizado: () => setState(() {}),
        ),
      ),
    );
  }

  void _mostrarSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Hace que el menú no ocupe toda la pantalla
            children: [
              const Text(
                '¿Qué ejercicio vas a hacer?', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),
              // Convertimos las llaves del mapa en una lista de widgets
              ...diario.keys.map((nombre) {
                // Obtenemos el objeto ejercicio para acceder a su imagen
                final eje = diario[nombre]!; 
                
                return ListTile(
                  // CAMBIO AQUÍ: Usamos la imagen en lugar del icono
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      eje.imagePath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.fitness_center),
                    ),
                  ),
                  title: Text(nombre),
                  onTap: () {
                    Navigator.pop(context); // Cierra el menú
                    _irADetalle(nombre);    // Abre la pantalla de peso/repes
                  },
                );
              }).toList(),
              const SizedBox(height: 20), // Espacio extra al final
            ],
          ),
        );
      },
    );
  }
}