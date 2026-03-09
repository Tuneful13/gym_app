import 'package:flutter/material.dart';
import 'package:gym_app/selector_ejercicio.dart';
import 'models.dart';
import 'detalle_ejercicio.dart';

class ListaEjercicios extends StatefulWidget {
  const ListaEjercicios({super.key});

  @override
  State<ListaEjercicios> createState() => _ListaEjerciciosState();
}

class _ListaEjerciciosState extends State<ListaEjercicios> {
  // Datos maestros de la aplicación
  Map<String, Ejercicio> diario = {
    'Bench Press': Ejercicio('Bench Press', 'assets/bench.png', 'Pecho', []),
    'Overhead Press': Ejercicio('Overhead Press', 'assets/overhead.png', 'Hombro', []),
    'Fondos': Ejercicio('Fondos', 'assets/dips.png', 'Triceps', []),
    'Dominadas': Ejercicio('Dominadas', 'assets/pullups.png', 'Espalda', []),
    'Curl de Biceps': Ejercicio('Curl de Biceps', 'assets/curl.png', 'Biceps', []),
    'Squat': Ejercicio('Squat', 'assets/squat.png', 'Pierna', []),
    'Deadlift': Ejercicio('Deadlift', 'assets/deadlift.png', 'Pierna', []),
    'Plancha': Ejercicio('Plancha', 'assets/plank.png', 'Core', []),
  };

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

  @override
  Widget build(BuildContext context) {
    final todosLosGrupos = ['Pecho', 'Hombro', 'Triceps', 'Espalda', 'Biceps', 'Pierna', 'Core'];
    final ejerciciosConDatos = diario.values.where((e) => e.series.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...todosLosGrupos.map((grupo) {
            final ejerciciosDeEsteGrupo = ejerciciosConDatos.where((e) => e.grupo == grupo).toList();
            if (ejerciciosDeEsteGrupo.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Text(
                    grupo.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.blue.shade900,
                      letterSpacing: 1.1
                    ),
                  ),
                ),
                ...ejerciciosDeEsteGrupo.map((eje) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        eje.imagePath,
                        width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center),
                      ),
                    ),
                    title: Text(eje.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    // subtitle: Text('${eje.series.length} series completadas'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _irADetalle(eje.nombre),
                  ),
                )),
                const SizedBox(height: 10),
              ],
            );
          }),
          _botonAgregar(),
        ],
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
        ),
      ),
    );
  }

  void _mostrarSelector() {
    SelectorEjercicio.mostrar(
      context: context,
      diario: diario,
      onSeleccionado: (nombre) {
        _irADetalle(nombre); // Cuando el selector avisa, vamos al detalle
      },
    );
  }
}