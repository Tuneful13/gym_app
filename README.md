# Gym App

App en Flutter para registrar entrenamientos de fuerza y seguir el progreso por ejercicio. Los datos se guardan en local, sin cuenta ni conexión.

## Funcionalidades

- **Registro de series**: peso y repeticiones por sesión, con historial editable.
- **Gráficos de progreso**: evolución del peso por número de reps y e1RM estimado (fórmula de Epley).
- **Ejercicios personalizados**: nombre, grupo muscular, foto (cámara o galería) y notas.
- **Diagrama muscular**: músculos principales y secundarios marcados sobre un diagrama del cuerpo.
- **Filtros por grupo muscular** en la pantalla de inicio.

## Stack

- [Flutter](https://flutter.dev) (Dart SDK ^3.10)
- [Hive](https://pub.dev/packages/hive) para la persistencia local
- [fl_chart](https://pub.dev/packages/fl_chart) para los gráficos
- [image_picker](https://pub.dev/packages/image_picker) para las fotos

## Puesta en marcha

```bash
flutter pub get
flutter run
```

Si modificas los modelos de [lib/models.dart](lib/models.dart), regenera los adaptadores de Hive:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Estructura

```
lib/
├── main.dart                # Arranque e inicialización de Hive
├── models.dart              # Modelos: Ejercicio, Sesion, Serie
├── lista_ejercicios.dart    # Pantalla de inicio
├── detalle_ejercicio.dart   # Registro, historial y gráficos
├── crear_ejercicio.dart     # Crear o editar ejercicios
├── selector_ejercicio.dart  # Selector de ejercicios
└── muscle_diagram.dart      # Diagrama muscular interactivo
```
