import 'dart:io' as dart;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gym_app/selector_ejercicio.dart';
import 'models.dart';
import 'detalle_ejercicio.dart';
import 'crear_ejercicio.dart';

class ListaEjercicios extends StatefulWidget {
  const ListaEjercicios({super.key});

  @override
  State<ListaEjercicios> createState() => _ListaEjerciciosState();
}

class _ListaEjerciciosState extends State<ListaEjercicios> {
  late Box<Ejercicio> _box;
  bool _cargando = true;

  // Ejercicios predefinidos
  final Map<String, Ejercicio> _predefinidos = {
    'Bench Press': Ejercicio('Bench Press', 'assets/bench.png', 'Pecho', [],
      musculosPrincipales: ['pecho'],
      musculosSecundarios: ['triceps', 'deltoides'],
    ),
    'Overhead Press': Ejercicio('Overhead Press', 'assets/overhead.png', 'Hombro', [],
      musculosPrincipales: ['deltoides'],
      musculosSecundarios: ['triceps', 'trapecio'],
    ),
    'Fondos': Ejercicio('Fondos', 'assets/dips.png', 'Triceps', [],
      musculosPrincipales: ['triceps'],
      musculosSecundarios: ['pecho', 'deltoides'],
    ),
    'Dominadas': Ejercicio('Dominadas', 'assets/pullups.png', 'Espalda', [],
      musculosPrincipales: ['dorsales'],
      musculosSecundarios: ['biceps', 'trapecio'],
    ),
    'Curl de Biceps': Ejercicio('Curl de Biceps', 'assets/curl.png', 'Biceps', [],
      musculosPrincipales: ['biceps'],
      musculosSecundarios: [],
    ),
    'Squat': Ejercicio('Squat', 'assets/squat.png', 'Pierna', [],
      musculosPrincipales: ['cuadriceps', 'gluteos'],
      musculosSecundarios: ['isquiotibiales', 'core'],
    ),
    'Deadlift': Ejercicio('Deadlift', 'assets/deadlift.png', 'Pierna', [],
      musculosPrincipales: ['dorsales', 'isquiotibiales', 'gluteos'],
      musculosSecundarios: ['trapecio', 'core', 'biceps'],
    ),
    'Plancha': Ejercicio('Plancha', 'assets/plank.png', 'Core', [],
      musculosPrincipales: ['core', 'abdominales'],
      musculosSecundarios: ['deltoides'],
    ),
  };

  Map<String, Ejercicio> diario = {};

  @override
  void initState() {
    super.initState();
    _inicializarHive();
  }

  Future<void> _inicializarHive() async {
    _box = await Hive.openBox<Ejercicio>('ejercicios');

    // Si la caja está vacía, metemos los predefinidos
    if (_box.isEmpty) {
      for (final entry in _predefinidos.entries) {
        await _box.put(entry.key, entry.value);
      }
    } else {
      // Si faltan predefinidos (primera vez tras actualizar), los añadimos
      for (final entry in _predefinidos.entries) {
        if (!_box.containsKey(entry.key)) {
          await _box.put(entry.key, entry.value);
        }
      }
    }

    setState(() {
      diario = {for (final key in _box.keys) key.toString(): _box.get(key)!};
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    for (final entry in diario.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  void _irADetalle(String nombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEjercicio(
          ejercicio: diario[nombre]!,
          onActualizado: () {
            _guardar();
            setState(() {});
          },
        ),
      ),
    );
  }

  void _editarEjercicio(Ejercicio eje) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEjercicio(
          ejercicioExistente: eje,
          onGuardado: (actualizado) async {
            setState(() {
              diario.remove(eje.nombre);
              diario[actualizado.nombre] = actualizado;
            });
            await _box.delete(eje.nombre);
            await _box.put(actualizado.nombre, actualizado);
          },
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(Ejercicio eje) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: Text('¿Eliminar "${eje.nombre}" y todos sus registros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              setState(() => diario.remove(eje.nombre));
              await _box.delete(eje.nombre);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final todosLosGrupos = ['Pecho', 'Hombro', 'Triceps', 'Espalda', 'Biceps', 'Pierna', 'Core'];
    final ejerciciosConDatos = diario.values.where((e) => e.series.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...todosLosGrupos.map((grupo) {
            final ejerciciosDeEsteGrupo = ejerciciosConDatos
                .where((e) => e.grupo == grupo)
                .toList();
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
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                ...ejerciciosDeEsteGrupo.map((eje) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: eje.imagenPersonalizada != null
                        ? Image.file(
                            dart.File(eje.imagenPersonalizada!),
                            width: 50, height: 50, fit: BoxFit.cover,
                          )
                          : Image.asset(
                              eje.imagePath,
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.fitness_center),
                            ),
                    ),
                    title: Text(eje.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${eje.series.length} registros'),
                    trailing: eje.esPersonalizado
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () => _editarEjercicio(eje),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmarEliminar(eje),
                              ),
                            ],
                          )
                        : const Icon(Icons.chevron_right),
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
          label: const Text('AGREGAR EJERCICIO',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        _irADetalle(nombre);
      },
      onCreado: (ejercicio) async {
        setState(() {
          diario[ejercicio.nombre] = ejercicio;
        });
        await _box.put(ejercicio.nombre, ejercicio);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleEjercicio(
                ejercicio: diario[ejercicio.nombre]!,
                onActualizado: () {
                  _guardar();
                  setState(() {});
                },
              ),
            ),
          );
        }
      },
    );
  }
}