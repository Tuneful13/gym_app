// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SerieAdapter extends TypeAdapter<Serie> {
  @override
  final int typeId = 0;

  @override
  Serie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Serie(
      fields[0] as String,
      fields[1] as String,
      fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Serie obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.peso)
      ..writeByte(1)
      ..write(obj.repes)
      ..writeByte(2)
      ..write(obj.fecha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EjercicioAdapter extends TypeAdapter<Ejercicio> {
  @override
  final int typeId = 1;

  @override
  Ejercicio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ejercicio(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      (fields[3] as List).cast<Serie>(),
      musculosPrincipales: (fields[4] as List).cast<String>(),
      musculosSecundarios: (fields[5] as List).cast<String>(),
      esPersonalizado: fields[6] as bool,
      imagenPersonalizada: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Ejercicio obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.grupo)
      ..writeByte(3)
      ..write(obj.series)
      ..writeByte(4)
      ..write(obj.musculosPrincipales)
      ..writeByte(5)
      ..write(obj.musculosSecundarios)
      ..writeByte(6)
      ..write(obj.esPersonalizado)
      ..writeByte(7)
      ..write(obj.imagenPersonalizada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EjercicioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
