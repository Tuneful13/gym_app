import 'package:flutter/material.dart';
import 'models.dart';
import 'crear_ejercicio.dart';
import 'dart:io';

class SelectorEjercicio {
  static void mostrar({
    required BuildContext context,
    required Map<String, Ejercicio> diario,
    required Function(String) onSeleccionado,
    required Function(Ejercicio) onCreado,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '¿Qué ejercicio vas a hacer?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Botón crear
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // cierra el selector
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrearEjercicio(
                                onGuardado: (ejercicio) {
                                  onCreado(ejercicio);
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nuevo'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...diario.keys.map((nombre) {
                        final eje = diario[nombre]!;
                        return ListTile(
                          leading: _buildLeading(eje),
                          title: Text(nombre),
                          subtitle: eje.esPersonalizado
                              ? Text(eje.grupo,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500))
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onSeleccionado(nombre);
                          },
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildLeading(Ejercicio eje) {
    if (eje.imagenPersonalizada != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(eje.imagenPersonalizada!),
          width: 40, height: 40, fit: BoxFit.cover,
        ),
      );
    }
    if (eje.imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          eje.imagePath,
          width: 40, height: 40, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.blue.shade50,
      child: Icon(Icons.fitness_center, color: Colors.blue.shade900, size: 20),
    );
  }
}