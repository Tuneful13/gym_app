class Serie {
  String peso;
  final String repes;
  final DateTime fecha;

  Serie(this.peso, this.repes, this.fecha);
}

class Ejercicio {
  final String nombre;
  final String imagePath;
  final String grupo;
  List<Serie> series;

  Ejercicio(this.nombre, this.imagePath, this.grupo, this.series);

  // Devuelve solo el mejor peso por rep count (para la vista de récords)
  List<Serie> get records {
    final Map<String, Serie> mejores = {};
    for (final s in series) {
      if (!mejores.containsKey(s.repes) ||
          (double.tryParse(s.peso) ?? 0) > (double.tryParse(mejores[s.repes]!.peso) ?? 0)) {
        mejores[s.repes] = s;
      }
    }
    return mejores.values.toList()
      ..sort((a, b) => (int.tryParse(a.repes) ?? 0).compareTo(int.tryParse(b.repes) ?? 0));
  }
}