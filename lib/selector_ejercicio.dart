import 'package:flutter/material.dart';
import 'models.dart';

class SelectorEjercicio {
  // Función estática para que no necesites instanciar la clase
  static void mostrar({
    required BuildContext context,
    required Map<String, Ejercicio> diario,
    required Function(String) onSeleccionado,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué ejercicio vas a hacer?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Generamos la lista simple que pediste
              ...diario.keys.map((nombre) {
                final eje = diario[nombre]!;
                return ListTile(
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
                    onSeleccionado(nombre); // Ejecuta la lógica de la pantalla principal
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}