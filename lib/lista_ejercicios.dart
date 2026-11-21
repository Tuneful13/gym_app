import 'dart:io' as dart;
import 'actualizador.dart';
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
  String? _grupoFiltro;

  // Ejercicios predefinidos
  final Map<String, Ejercicio> _predefinidos = {
    'Bench Press': Ejercicio(
      'Bench Press', 'assets/bench.png', 'Pecho',
      [
        Sesion(DateTime(2026, 10, 16), [
          Serie('60', '5', DateTime(2026, 10, 16)),
          Serie('70', '5', DateTime(2026, 10, 16)),
          Serie('75', '3', DateTime(2026, 10, 16)),
          Serie('75', '3', DateTime(2026, 10, 16)),
        ]),
        Sesion(DateTime(2026, 10, 12), [
          Serie('60', '5', DateTime(2026, 10, 12)),
          Serie('65', '5', DateTime(2026, 10, 12)),
          Serie('70', '5', DateTime(2026, 10, 12)),
        ]),
        Sesion(DateTime(2026, 10, 5), [
          Serie('62.5', '5', DateTime(2026, 10, 5)),
          Serie('67.5', '5', DateTime(2026, 10, 5)),
          Serie('65', '8', DateTime(2026, 10, 5)),
        ]),
        Sesion(DateTime(2026, 9, 28), [
          Serie('60', '5', DateTime(2026, 9, 28)),
          Serie('65', '5', DateTime(2026, 9, 28)),
          Serie('62.5', '8', DateTime(2026, 9, 28)),
        ]),
        Sesion(DateTime(2026, 9, 21), [
          Serie('60', '5', DateTime(2026, 9, 21)),
          Serie('62.5', '5', DateTime(2026, 9, 21)),
          Serie('60', '8', DateTime(2026, 9, 21)),
        ]),
        Sesion(DateTime(2026, 9, 14), [
          Serie('57.5', '5', DateTime(2026, 9, 14)),
          Serie('60', '5', DateTime(2026, 9, 14)),
          Serie('57.5', '8', DateTime(2026, 9, 14)),
        ]),
        Sesion(DateTime(2026, 9, 7), [
          Serie('55', '5', DateTime(2026, 9, 7)),
          Serie('57.5', '5', DateTime(2026, 9, 7)),
          Serie('55', '8', DateTime(2026, 9, 7)),
        ]),
        Sesion(DateTime(2026, 8, 31), [
          Serie('52.5', '5', DateTime(2026, 8, 31)),
          Serie('55', '5', DateTime(2026, 8, 31)),
        ]),
        Sesion(DateTime(2026, 8, 24), [
          Serie('50', '5', DateTime(2026, 8, 24)),
          Serie('52.5', '5', DateTime(2026, 8, 24)),
          Serie('50', '10', DateTime(2026, 8, 24)),
        ]),
        Sesion(DateTime(2026, 8, 17), [
          Serie('47.5', '5', DateTime(2026, 8, 17)),
          Serie('50', '5', DateTime(2026, 8, 17)),
          Serie('47.5', '10', DateTime(2026, 8, 17)),
        ]),
      ],
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

  // ignore: unused_field
  static const int _schemaVersion = 3;

  Map<String, Ejercicio> diario = {};

  @override
  void initState() {
    super.initState();
    _inicializarHive();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) comprobarActualizacion(context);
    });
  }

  Future<void> _inicializarHive() async {
    try {
      _box = await Hive.openBox<Ejercicio>('ejercicios_v3');
      if (_box.isNotEmpty) {
        _box.values.first.sesiones.length;
      }
    } catch (_) {
      await _box.deleteFromDisk();
      _box = await Hive.openBox<Ejercicio>('ejercicios_v3');
    }


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
    final ejerciciosConDatos = diario.values.where((e) => e.sesiones.isNotEmpty).toList();
    final gruposConDatos = todosLosGrupos
        .where((g) => ejerciciosConDatos.any((e) => e.grupo == g))
        .toList();
    final gruposFiltrados = _grupoFiltro == null
        ? todosLosGrupos
        : [_grupoFiltro!];

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarSelector,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar ejercicio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          if (gruposConDatos.isNotEmpty)
            _chipsFiltro(gruposConDatos),
          ...gruposFiltrados.map((grupo) {
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
                    subtitle: Text('${eje.sesiones.length} sesiones · ${eje.totalSets} sets'),
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
        ],
      ),
    );
  }

  Widget _chipsFiltro(List<String> grupos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Todos', _grupoFiltro == null, () {
              setState(() => _grupoFiltro = null);
            }),
            const SizedBox(width: 8),
            ...grupos.map((g) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(g, _grupoFiltro == g, () {
                setState(() => _grupoFiltro = _grupoFiltro == g ? null : g);
              }),
            )),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool seleccionado, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue.shade900 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? Colors.blue.shade900 : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: seleccionado ? Colors.white : Colors.grey.shade700,
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