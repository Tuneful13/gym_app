# Gym App

App en Flutter para registrar entrenamientos de fuerza y seguir el progreso por ejercicio. Los datos se guardan en local, sin cuenta ni conexión.

## Descargar la APK

- **[Última versión](https://github.com/Tuneful13/gym_app/releases/latest)**: la APK está en "Assets".
- Descarga directa de la 1.0.2: [gym_app-1.0.2.apk](https://github.com/Tuneful13/gym_app/releases/download/v1.0.2/gym_app-1.0.2.apk)
- **Actualizaciones**: desde la 1.0.2, al abrir la app comprueba si hay una release nueva en GitHub y ofrece descargarla e instalarla. La primera vez Android pide permiso para "instalar apps desconocidas".

## Funcionalidades

- **Registro de series**: peso y repeticiones por sesión, con historial editable.
- **Gráficos de progreso**: evolución del peso por número de reps y e1RM estimado (fórmula de Epley).
- **Ejercicios personalizados**: nombre, grupo muscular, foto (cámara o galería) y notas.
- **Diagrama muscular**: músculos principales y secundarios marcados sobre un diagrama del cuerpo.
- **Filtros por grupo muscular** en la pantalla de inicio.
- **Actualización desde la app**: avisa de las versiones nuevas publicadas en GitHub.

## Stack

- [Flutter](https://flutter.dev) (Dart SDK ^3.10)
- [Hive](https://pub.dev/packages/hive) para la persistencia local
- [fl_chart](https://pub.dev/packages/fl_chart) para los gráficos
- [image_picker](https://pub.dev/packages/image_picker) para las fotos

## Publicar una versión nueva

1. Sube `version:` en `pubspec.yaml` (por ejemplo `1.0.3+4`).
2. `flutter build apk --release`
3. Crea una release en GitHub con la etiqueta `v1.0.3` y adjunta la APK. Las apps instaladas la verán al abrirse.

Todas las versiones deben compilarse con la misma firma (ahora la de depuración de este PC); si cambia, Android no deja instalar encima.

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
├── muscle_diagram.dart      # Diagrama muscular interactivo
└── actualizador.dart        # Busca releases nuevas en GitHub y las instala
```
