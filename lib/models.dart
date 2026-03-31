import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class Serie extends HiveObject {
  @HiveField(0)
  String peso;

  @HiveField(1)
  final String repes;

  @HiveField(2)
  final DateTime fecha;

  Serie(this.peso, this.repes, this.fecha);
}

@HiveType(typeId: 1)
class Ejercicio extends HiveObject {
  @HiveField(0)
  final String nombre;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String grupo;

  @HiveField(3)
  List<Serie> series;

  @HiveField(4)
  List<String> musculosPrincipales;

  @HiveField(5)
  List<String> musculosSecundarios;

  @HiveField(6)
  final bool esPersonalizado;

  @HiveField(7)
  final String? imagenPersonalizada;

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

  Serie? get mejorSerie {
    if (records.isEmpty) return null;
    return records.reduce((a, b) {
      double oneRMA = (double.tryParse(a.repes) ?? 0) <= 1
          ? (double.tryParse(a.peso) ?? 0)
          : (double.tryParse(a.peso) ?? 0) * (1 + (double.tryParse(a.repes) ?? 0) / 30);
      double oneRMB = (double.tryParse(b.repes) ?? 0) <= 1
          ? (double.tryParse(b.peso) ?? 0)
          : (double.tryParse(b.peso) ?? 0) * (1 + (double.tryParse(b.repes) ?? 0) / 30);
      return oneRMA >= oneRMB ? a : b;
    });
  }

  double get oneRMActual {
    final s = mejorSerie;
    if (s == null) return 0;
    double w = double.tryParse(s.peso) ?? 0;
    double r = double.tryParse(s.repes) ?? 0;
    return r <= 1 ? w : w * (1 + r / 30);
  }

  String? get imagenEfectiva =>
      imagenPersonalizada ?? (imagePath.isNotEmpty ? imagePath : null);
}