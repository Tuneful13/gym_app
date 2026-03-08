class Serie {
  String peso;
  final String repes;
  Serie(this.peso, this.repes);
}

class Ejercicio {
  final String nombre;
  final String imagePath;
  final String grupo;
  List<Serie> series;
  
  Ejercicio(this.nombre, this.imagePath, this.grupo, this.series);
}