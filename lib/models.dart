class Serie {
  String peso;
  final String repes;
  Serie(this.peso, this.repes);
}

class Ejercicio {
  final String nombre;
  final String imagePath;
  List<Serie> series;
  
  Ejercicio(this.nombre, this.imagePath, this.series);
}