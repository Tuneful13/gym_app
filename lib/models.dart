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

@HiveType(typeId: 2)
class Sesion extends HiveObject {
  @HiveField(0)
  DateTime fecha;

  @HiveField(1)
  List<Serie> sets;

  Sesion(this.fecha, this.sets);
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
  List<Sesion> sesiones;

  @HiveField(4)
  List<String> musculosPrincipales;

  @HiveField(5)
  List<String> musculosSecundarios;

  @HiveField(6)
  final bool esPersonalizado;

  @HiveField(7)
  final String? imagenPersonalizada;

  @HiveField(8)
  String? nota;

  Ejercicio(
    this.nombre,
    this.imagePath,
    this.grupo,
    this.sesiones, {
    this.musculosPrincipales = const [],
    this.musculosSecundarios = const [],
    this.esPersonalizado = false,
    this.imagenPersonalizada,
    this.nota,
  });

  int get totalSets => sesiones.fold(0, (sum, s) => sum + s.sets.length);

  String? get imagenEfectiva =>
      imagenPersonalizada ?? (imagePath.isNotEmpty ? imagePath : null);
}
