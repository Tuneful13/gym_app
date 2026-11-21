import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Comprueba si hay una release nueva en GitHub y ofrece instalarla.
const _urlUltimaRelease =
    'https://api.github.com/repos/Tuneful13/gym_app/releases/latest';

class ReleaseDisponible {
  final String version;
  final String urlApk;
  final String? sha256;
  final String notas;

  const ReleaseDisponible({
    required this.version,
    required this.urlApk,
    this.sha256,
    this.notas = '',
  });
}

/// Compara versiones tipo "1.2.3" (admite "v1.2.3" y sufijos "+5", que se ignoran).
/// Devuelve >0 si [a] es mayor, <0 si es menor y 0 si son iguales.
int compararVersiones(String a, String b) {
  List<int> partes(String v) => v
      .trim()
      .replaceFirst(RegExp(r'^[vV]'), '')
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p) ?? 0)
      .toList();
  final pa = partes(a), pb = partes(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x - y;
  }
  return 0;
}

/// Lee la respuesta de la API de GitHub. Devuelve null si no hay APK o no es más nueva.
ReleaseDisponible? releaseDesdeJson(Map<String, dynamic> json, String versionActual) {
  final tag = json['tag_name'] as String?;
  if (tag == null || compararVersiones(tag, versionActual) <= 0) return null;
  final assets = (json['assets'] as List?) ?? const [];
  for (final a in assets.cast<Map<String, dynamic>>()) {
    final nombre = (a['name'] as String?) ?? '';
    final url = a['browser_download_url'] as String?;
    if (nombre.toLowerCase().endsWith('.apk') && url != null) {
      final digest = a['digest'] as String?;
      return ReleaseDisponible(
        version: tag.replaceFirst(RegExp(r'^[vV]'), ''),
        urlApk: url,
        sha256: digest != null && digest.startsWith('sha256:') ? digest.substring(7) : null,
        notas: (json['body'] as String?)?.trim() ?? '',
      );
    }
  }
  return null;
}

Future<ReleaseDisponible?> buscarActualizacion() async {
  if (!Platform.isAndroid) return null;
  try {
    final info = await PackageInfo.fromPlatform();
    final r = await http.get(Uri.parse(_urlUltimaRelease),
        headers: {'Accept': 'application/vnd.github+json'}).timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) return null;
    return releaseDesdeJson(jsonDecode(r.body) as Map<String, dynamic>, info.version);
  } catch (e) {
    debugPrint('No se pudo comprobar si hay actualización: $e');
    return null;
  }
}

/// Borra los .apk de actualizaciones anteriores (ota_update los guarda en
/// files/ota_update). Tras instalar, la app se reinicia y aquí se limpian.
Future<void> borrarApksDescargados() async {
  if (!Platform.isAndroid) return;
  try {
    final dir = Directory('${(await getApplicationSupportDirectory()).path}/ota_update');
    if (!await dir.exists()) return;
    await for (final f in dir.list()) {
      if (f is File && f.path.toLowerCase().endsWith('.apk')) await f.delete();
    }
  } catch (e) {
    debugPrint('No se pudieron borrar los APK descargados: $e');
  }
}

/// Llamar al abrir la app: limpia APK viejos y, si hay versión nueva, pregunta y la instala.
Future<void> comprobarActualizacion(BuildContext context) async {
  await borrarApksDescargados();
  if (!context.mounted) return;
  final release = await buscarActualizacion();
  if (release == null || !context.mounted) return;
  final aceptar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Nueva versión ${release.version}'),
      content: Text(release.notas.isEmpty
          ? '¿Quieres descargarla e instalarla ahora?'
          : '${release.notas}\n\n¿Quieres descargarla e instalarla ahora?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Más tarde')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Actualizar')),
      ],
    ),
  );
  if (aceptar == true && context.mounted) {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoDescarga(release: release),
    );
  }
}

class _DialogoDescarga extends StatefulWidget {
  const _DialogoDescarga({required this.release});
  final ReleaseDisponible release;

  @override
  State<_DialogoDescarga> createState() => _DialogoDescargaState();
}

class _DialogoDescargaState extends State<_DialogoDescarga> {
  double? _progreso;
  String? _error;
  bool _cerrado = false;

  void _cerrar() {
    if (_cerrado || !mounted) return;
    _cerrado = true;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    OtaUpdate()
        .execute(
          widget.release.urlApk,
          destinationFilename: 'gym_app-${widget.release.version}.apk',
          sha256checksum: widget.release.sha256,
        )
        .listen(_alEvento, onError: (Object e) => _fallo('$e'));
  }

  void _alEvento(OtaEvent e) {
    if (!mounted || _cerrado) return;
    switch (e.status) {
      case OtaStatus.DOWNLOADING:
        setState(() => _progreso = (double.tryParse(e.value ?? '') ?? 0) / 100);
      case OtaStatus.INSTALLING:
      case OtaStatus.INSTALLATION_DONE:
        // Android muestra ahora su pantalla de instalación.
        _cerrar();
      case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
        _fallo('Falta el permiso para instalar apps. Actívalo en los ajustes de Android '
            '("Instalar apps desconocidas") y vuelve a intentarlo.');
      case OtaStatus.CANCELED:
        _cerrar();
      default:
        _fallo('No se pudo actualizar: ${e.value ?? e.status.name}');
    }
  }

  void _fallo(String mensaje) {
    if (mounted && !_cerrado) setState(() => _error = mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_error == null ? 'Descargando ${widget.release.version}…' : 'Error'),
      content: _error != null
          ? Text(_error!)
          : Column(mainAxisSize: MainAxisSize.min, children: [
              LinearProgressIndicator(value: _progreso),
              const SizedBox(height: 12),
              Text(_progreso == null ? 'Empezando…' : '${(_progreso! * 100).round()} %'),
            ]),
      actions: [
        TextButton(
          onPressed: () {
            if (_error == null) OtaUpdate().cancel();
            _cerrar();
          },
          child: Text(_error == null ? 'Cancelar' : 'Cerrar'),
        ),
      ],
    );
  }
}
