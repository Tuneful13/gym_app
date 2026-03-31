class Serie {
  String peso;
  final String repes;
  final DateTime fecha;

  Serie(this.peso, this.repes, this.fecha);
}

class Ejercicio {
  final String nombre;
  final String imagePath;
  final String? imagenPersonalizada;
  final String grupo;
  List<Serie> series;
  List<String> musculosPrincipales;
  List<String> musculosSecundarios;
  final bool esPersonalizado;

  Ejercicio(
    this.nombre,
    this.imagePath,
    this.grupo,
    this.series, {
    this.musculosPrincipales = const [],
    this.musculosSecundarios = const [],
    this.esPersonalizado = false,
    this.imagenPersonalizada,
  });

  // ── Este getter es el que falta ──
  List<Serie> get records {
    final Map<String, Serie> mejores = {};
    for (final s in series) {
      if (!mejores.containsKey(s.repes) ||
          (double.tryParse(s.peso) ?? 0) >
              (double.tryParse(mejores[s.repes]!.peso) ?? 0)) {
        mejores[s.repes] = s;
      }
    }
    return mejores.values.toList()
      ..sort((a, b) =>
          (int.tryParse(a.repes) ?? 0).compareTo(int.tryParse(b.repes) ?? 0));
  }

  String? get imagenEfectiva =>
      imagenPersonalizada ?? (imagePath.isNotEmpty ? imagePath : null);
}