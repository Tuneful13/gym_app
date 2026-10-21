import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const List<Map<String, dynamic>> todosLosMusculosInfo = [
  {'id': 'pecho',         'label': 'Pecho'},
  {'id': 'deltoides',     'label': 'Deltoides'},
  {'id': 'biceps',        'label': 'Bíceps'},
  {'id': 'triceps',       'label': 'Tríceps'},
  {'id': 'abdominales',   'label': 'Abdominales'},
  {'id': 'dorsales',      'label': 'Dorsales'},
  {'id': 'trapecio',      'label': 'Trapecio'},
  {'id': 'core',          'label': 'Core'},
  {'id': 'cuadriceps',    'label': 'Cuádriceps'},
  {'id': 'gluteos',       'label': 'Glúteos'},
  {'id': 'isquiotibiales','label': 'Isquiotibiales'},
  {'id': 'gemelos',       'label': 'Gemelos'},
];

// ─── Paleta ──────────────────────────────────────────────────────────────────
const kColorMusculoPrincipal  = Color(0xFFF2434F);
const kColorMusculoSecundario = Color(0xFFFFA62B);

const _kFondoArriba = Color(0xFF1C2230);
const _kFondoAbajo  = Color(0xFF0F131B);
const _kEtiqueta    = Color(0xFF7D879A);

class _Tono {
  final Color arriba;
  final Color abajo;
  final Color halo;
  const _Tono(this.arriba, this.abajo, this.halo);

  static _Tono lerp(_Tono a, _Tono b, double t) => _Tono(
        Color.lerp(a.arriba, b.arriba, t)!,
        Color.lerp(a.abajo, b.abajo, t)!,
        Color.lerp(a.halo, b.halo, t)!,
      );
}

const _kTonoInactivo   = _Tono(Color(0xFF3B4558), Color(0xFF2A3242), Color(0x00F2434F));
const _kTonoPrincipal  = _Tono(Color(0xFFFF6A63), Color(0xFFD8283A), Color(0x99F2434F));
const _kTonoSecundario = _Tono(Color(0xFFFFC566), Color(0xFFF08A1C), Color(0x80FFA62B));
const _kTonoNeutro     = _Tono(Color(0xFF333C4D), Color(0xFF252C3A), Color(0x00000000));

// ─── Widget ──────────────────────────────────────────────────────────────────

/// Mapa muscular anatómico (vista frontal y posterior).
///
/// Si se pasa [onMuscleTap], cada músculo del diagrama es pulsable y devuelve
/// su id (los mismos que en [todosLosMusculosInfo]).
class MuscleDiagram extends StatefulWidget {
  final List<String> principales;
  final List<String> secundarios;
  final ValueChanged<String>? onMuscleTap;

  const MuscleDiagram({
    super.key,
    required this.principales,
    required this.secundarios,
    this.onMuscleTap,
  });

  @override
  State<MuscleDiagram> createState() => _MuscleDiagramState();
}

class _MuscleDiagramState extends State<MuscleDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );
  late final Animation<double> _curva =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  Map<String, _Tono> _desde = {};
  Map<String, _Tono> _hasta = {};

  Map<String, _Tono> _objetivo() => {
        for (final m in todosLosMusculosInfo)
          m['id'] as String: widget.principales.contains(m['id'])
              ? _kTonoPrincipal
              : widget.secundarios.contains(m['id'])
                  ? _kTonoSecundario
                  : _kTonoInactivo,
      };

  @override
  void initState() {
    super.initState();
    _hasta = _objetivo();
    _desde = _hasta;
  }

  @override
  void didUpdateWidget(MuscleDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nuevo = _objetivo();
    final cambia = nuevo.entries.any((e) => !identical(_hasta[e.key], e.value));
    if (!cambia) return;
    _desde = _tonosActuales();
    _hasta = nuevo;
    _ctrl.forward(from: 0);
  }

  Map<String, _Tono> _tonosActuales() => {
        for (final id in _hasta.keys)
          id: _Tono.lerp(_desde[id] ?? _hasta[id]!, _hasta[id]!, _curva.value),
      };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kFondoArriba, _kFondoAbajo],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Row(
          children: [
            Expanded(child: _figura(_Vista.frontal, 'FRONTAL')),
            Expanded(child: _figura(_Vista.posterior, 'POSTERIOR')),
          ],
        ),
      ),
    );
  }

  Widget _figura(_Vista vista, String etiqueta) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final size = constraints.biggest;
            final pintor = _CuerpoPainter(
              vista: vista,
              tono: (id) => _Tono.lerp(
                  _desde[id] ?? _hasta[id]!, _hasta[id]!, _curva.value),
              repaint: _curva,
            );
            final lienzo = CustomPaint(painter: pintor, size: size);
            if (widget.onMuscleTap == null) return lienzo;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final id = _musculoEn(vista, d.localPosition, size);
                if (id == null) return;
                HapticFeedback.selectionClick();
                widget.onMuscleTap!(id);
              },
              child: lienzo,
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(etiqueta,
            style: const TextStyle(
                fontSize: 9.5,
                color: _kEtiqueta,
                letterSpacing: 2,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Geometría ───────────────────────────────────────────────────────────────
// Las figuras se dibujan en un lienzo de 200×440 unidades. Cada parte se
// define para el lado izquierdo y se refleja sobre x = 100.

const double _kAncho = 200;
const double _kAlto = 440;
const double _kHueco = 1.5; // separación entre músculos, en unidades

enum _Vista { frontal, posterior }

class _Parte {
  final _Vista vista;
  final String? id; // null → zona sin músculo asignado (cabeza, manos…)
  final String d;
  final bool espejo;
  const _Parte(this.vista, this.id, this.d, {this.espejo = true});
}

class _Forma {
  final String? id;
  final Path path;
  final Rect bounds;
  _Forma(this.id, this.path) : bounds = path.getBounds();
}

final Float64List _kReflejo = Float64List.fromList(
    [-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, _kAncho, 0, 0, 1]);

final Map<_Vista, List<_Forma>> _formas = {
  for (final v in _Vista.values)
    v: [
      for (final p in _kPartes.where((p) => p.vista == v)) ...[
        _Forma(p.id, _parsearPath(p.d)),
        if (p.espejo) _Forma(p.id, _parsearPath(p.d).transform(_kReflejo)),
      ],
    ],
};

/// Mini‑parser de datos de path SVG (solo comandos absolutos M, L, C, Z).
Path _parsearPath(String d) {
  final tokens = RegExp(r'[MLCZ]|-?\d+(?:\.\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  final path = Path();
  var i = 0;
  double n() => double.parse(tokens[i++]);
  var cmd = 'M';
  while (i < tokens.length) {
    if (RegExp(r'^[MLCZ]$').hasMatch(tokens[i])) cmd = tokens[i++];
    switch (cmd) {
      case 'M':
        path.moveTo(n(), n());
        cmd = 'L';
      case 'L':
        path.lineTo(n(), n());
      case 'C':
        path.cubicTo(n(), n(), n(), n(), n(), n());
      case 'Z':
        path.close();
    }
  }
  return path;
}

/// Escala y desplazamiento para encajar el lienzo 200×440 en [size].
({double escala, Offset origen}) _encaje(Size size) {
  final escala = (size.width / _kAncho) < (size.height / _kAlto)
      ? size.width / _kAncho
      : size.height / _kAlto;
  return (
    escala: escala,
    origen: Offset((size.width - _kAncho * escala) / 2,
        (size.height - _kAlto * escala) / 2),
  );
}

String? _musculoEn(_Vista vista, Offset punto, Size size) {
  final e = _encaje(size);
  final local = (punto - e.origen) / e.escala;
  // Primero coincidencia exacta; si no, el músculo más cercano (dedos gordos).
  for (final f in _formas[vista]!.reversed) {
    if (f.id != null && f.path.contains(local)) return f.id;
  }
  String? mejor;
  var distMejor = 9.0;
  for (final f in _formas[vista]!) {
    if (f.id == null) continue;
    final dist = (f.bounds.center - local).distance -
        f.bounds.shortestSide / 2;
    if (dist < distMejor) {
      distMejor = dist;
      mejor = f.id;
    }
  }
  return mejor;
}

// ─── Pintor ──────────────────────────────────────────────────────────────────

class _CuerpoPainter extends CustomPainter {
  final _Vista vista;
  final _Tono Function(String id) tono;

  _CuerpoPainter({required this.vista, required this.tono, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final e = _encaje(size);
    canvas.save();
    canvas.translate(e.origen.dx, e.origen.dy);
    canvas.scale(e.escala);

    final formas = _formas[vista]!;
    final area = Offset.zero & const Size(_kAncho, _kAlto);

    // Foco de luz detrás de la figura y sombra en el suelo.
    const foco = Offset(_kAncho / 2, _kAlto * 0.4);
    canvas.drawCircle(
      foco,
      _kAlto * 0.45,
      Paint()
        ..shader = ui.Gradient.radial(
          foco,
          _kAlto * 0.45,
          [Colors.white.withValues(alpha: 0.07), Colors.white.withValues(alpha: 0)],
        ),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_kAncho / 2, 436), width: 90, height: 8),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Halo de los músculos activos (por debajo, para que asome en las juntas).
    for (final f in formas) {
      if (f.id == null) continue;
      final halo = tono(f.id!).halo;
      if (halo.a == 0) continue;
      canvas.drawPath(
        f.path,
        Paint()
          ..color = halo
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // Músculos: relleno con volumen, brillo superior y juntas recortadas.
    canvas.saveLayer(area.inflate(10), Paint());
    for (final f in formas) {
      final t = f.id == null ? _kTonoNeutro : tono(f.id!);
      canvas.drawPath(
        f.path,
        Paint()
          ..shader = ui.Gradient.linear(
            f.bounds.topLeft,
            f.bounds.bottomRight,
            [t.arriba, t.abajo],
          ),
      );
      canvas.drawPath(
        f.path,
        Paint()
          ..shader = ui.Gradient.linear(
            f.bounds.topCenter,
            f.bounds.centerLeft.translate(0, f.bounds.height * 0.15),
            [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0)],
          ),
      );
    }
    final junta = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kHueco
      ..strokeJoin = StrokeJoin.round;
    for (final f in formas) {
      canvas.drawPath(f.path, junta);
    }
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CuerpoPainter old) =>
      old.vista != vista || old.tono != tono;
}

// ─── Anatomía ────────────────────────────────────────────────────────────────

const _kPartes = <_Parte>[
  // ── Frontal ──
  _Parte(_Vista.frontal, null,
      'M100 10 C111 10 118 19 118 31 C118 44 110 55 100 55 C90 55 82 44 82 31 C82 19 89 10 100 10 Z', espejo: false),
  _Parte(_Vista.frontal, null,
      'M91 50 C93 57 93 66 92 74 C95 78 98 79 100 79 L100 56 C96 56 93 54 91 50 Z'),
  _Parte(_Vista.frontal, 'trapecio',
      'M90 58 C88 67 76 74 60 78 C70 80 81 80 90 77 C91 71 91 64 90 58 Z'),
  _Parte(_Vista.frontal, 'deltoides',
      'M62 80 C50 79 40 85 36 95 C33 105 34 117 37 127 L42 134 C45 123 49 113 54 105 C58 97 63 91 69 86 C67 82 65 81 62 80 Z'),
  _Parte(_Vista.frontal, 'pecho',
      'M98 82 C88 80 77 81 70 87 C63 94 58 103 55 112 C57 121 63 128 72 132 C82 136 92 135 98 131 Z'),
  _Parte(_Vista.frontal, 'dorsales',
      'M55 116 C59 124 63 129 68 133 C65 140 63 150 63 162 C60 148 57 132 55 116 Z'),
  _Parte(_Vista.frontal, 'biceps',
      'M43 137 C39 143 36 151 36 158 C36 164 39 168 43 169 C47 168 50 163 51 156 C53 146 54 132 54 119 C51 124 47 130 43 137 Z'),
  _Parte(_Vista.frontal, null,
      'M36 172 C30 180 27 194 26 208 C25 218 25 228 26 236 L31 236 C31 222 33 207 37 193 C39 185 39 178 36 172 Z'),
  _Parte(_Vista.frontal, null,
      'M41 173 C47 174 50 181 49 191 C47 206 42 222 37 236 L34 236 C34 222 37 207 40 194 C41 186 42 179 41 173 Z'),
  _Parte(_Vista.frontal, null,
      'M26 240 L36 240 C39 247 40 256 38 265 C36 272 33 276 30 276 C26 276 23 272 22 265 C21 256 23 247 26 240 Z'),
  _Parte(_Vista.frontal, 'abdominales',
      'M98 138 L98 155 C93 156 89 156 85 155 C84 149 84 144 85 140 C89 138 94 137 98 138 Z'),
  _Parte(_Vista.frontal, 'abdominales',
      'M98 159 L98 177 C93 178 89 178 85 177 C84 171 84 165 85 159 C89 158 94 158 98 159 Z'),
  _Parte(_Vista.frontal, 'abdominales',
      'M98 181 L98 199 C93 200 89 200 85 199 C84 193 84 187 85 181 C89 180 94 180 98 181 Z'),
  _Parte(_Vista.frontal, 'abdominales',
      'M98 203 L98 236 C95 238 92 234 89 227 C86 219 85 211 85 203 C89 202 94 202 98 203 Z'),
  _Parte(_Vista.frontal, null,
      'M67 137 C71 137 75 139 78 141 C75 144 71 145 66 144 Z'),
  _Parte(_Vista.frontal, null,
      'M65 148 C68 149 71 151 73 153 C70 156 67 157 64 157 Z'),
  _Parte(_Vista.frontal, 'core',
      'M81 141 C76 152 70 162 64 172 C64 188 65 206 67 221 C73 228 79 234 85 240 C83 228 82 214 81 202 C80 182 80 160 81 141 Z'),
  _Parte(_Vista.frontal, 'cuadriceps',
      'M64 226 C58 242 56 266 57 288 C58 302 62 313 68 322 C70 304 71 284 72 264 C72 250 69 237 64 226 Z'),
  _Parte(_Vista.frontal, 'cuadriceps',
      'M67 229 C73 235 78 240 83 245 C87 263 87 284 85 302 C84 310 81 316 77 322 L69 322 C71 304 72 284 73 264 C73 252 71 240 67 229 Z'),
  _Parte(_Vista.frontal, 'cuadriceps',
      'M87 284 C92 292 94 304 92 316 C90 323 85 326 79 326 L78 324 C82 317 85 310 86 302 C87 296 87 290 87 284 Z'),
  _Parte(_Vista.frontal, null,
      'M85 245 C89 247 93 248 97 247 C96 262 95 276 92 290 C90 287 89 285 88 282 C88 268 87 256 85 245 Z'),
  _Parte(_Vista.frontal, null,
      'M78 326 C82 326 85 330 85 335 C85 340 82 343 78 343 C74 343 71 340 71 335 C71 330 74 326 78 326 Z'),
  _Parte(_Vista.frontal, null,
      'M68 340 C64 352 63 368 66 386 C68 398 71 406 74 412 L78 412 C77 396 76 378 76 362 C76 354 74 346 68 340 Z'),
  _Parte(_Vista.frontal, 'gemelos',
      'M84 342 C90 348 93 358 92 372 C91 384 87 394 83 400 C81 386 80 372 80 360 C80 352 81 346 84 342 Z'),
  _Parte(_Vista.frontal, null,
      'M73 415 L85 415 C88 422 90 429 87 433 C81 436 71 436 66 433 C65 427 70 421 73 415 Z'),

  // ── Posterior ──
  _Parte(_Vista.posterior, null,
      'M100 10 C111 10 118 19 118 31 C118 44 110 55 100 55 C90 55 82 44 82 31 C82 19 89 10 100 10 Z', espejo: false),
  _Parte(_Vista.posterior, 'trapecio',
      'M100 54 C97 54 94 55 92 58 C90 66 82 72 60 79 C66 85 72 91 78 99 C85 121 92 152 100 188 Z'),
  _Parte(_Vista.posterior, 'deltoides',
      'M60 81 C48 80 39 86 35 96 C33 107 34 119 38 130 L42 135 C47 122 53 110 61 101 C66 95 70 90 68 85 Z'),
  _Parte(_Vista.posterior, null,
      'M70 89 C74 93 77 99 79 104 C82 116 84 127 84 137 C76 134 68 128 62 120 C60 112 62 103 70 89 Z'),
  _Parte(_Vista.posterior, 'dorsales',
      'M58 118 C64 127 73 135 85 141 C90 154 94 170 96 186 C92 195 87 203 82 211 C76 207 71 201 67 193 C65 172 62 148 58 118 Z'),
  _Parte(_Vista.posterior, 'core',
      'M98 192 C94 199 89 206 85 213 C85 221 87 228 91 233 L98 233 Z'),
  _Parte(_Vista.posterior, 'gluteos',
      'M98 240 C95 231 87 224 77 222 C69 222 63 227 61 235 C57 247 57 259 60 268 C65 279 77 284 89 282 C95 280 98 275 98 268 Z'),
  _Parte(_Vista.posterior, 'gluteos',
      'M67 200 C72 206 78 213 83 219 C75 218 67 221 62 228 C62 218 64 208 67 200 Z'),
  _Parte(_Vista.posterior, 'isquiotibiales',
      'M62 276 C59 292 60 310 66 330 C71 318 74 302 75 287 C70 285 66 281 62 276 Z'),
  _Parte(_Vista.posterior, 'isquiotibiales',
      'M79 288 C85 287 91 285 96 280 C95 298 92 316 85 332 C80 324 77 310 77 298 Z'),
  _Parte(_Vista.posterior, 'triceps',
      'M43 138 C38 145 35 153 36 162 C37 168 40 172 44 172 C48 170 51 164 52 156 C53 145 54 131 55 118 C51 123 47 130 43 138 Z'),
  _Parte(_Vista.posterior, null,
      'M36 175 C30 183 27 196 26 210 C25 220 25 229 26 236 L31 236 C31 222 33 207 37 194 C39 186 39 180 36 175 Z'),
  _Parte(_Vista.posterior, null,
      'M41 175 C47 176 50 183 49 193 C47 207 42 222 37 236 L34 236 C34 222 37 207 40 195 C41 187 42 181 41 175 Z'),
  _Parte(_Vista.posterior, null,
      'M26 240 L36 240 C39 247 40 256 38 265 C36 272 33 276 30 276 C26 276 23 272 22 265 C21 256 23 247 26 240 Z'),
  _Parte(_Vista.posterior, 'gemelos',
      'M67 336 C62 348 62 364 66 377 C69 384 73 387 77 384 C78 368 77 350 73 337 Z'),
  _Parte(_Vista.posterior, 'gemelos',
      'M80 337 C87 342 92 352 92 366 C92 378 87 387 81 386 C79 370 78 352 80 337 Z'),
  _Parte(_Vista.posterior, 'gemelos',
      'M67 383 C71 387 76 390 80 390 C84 390 88 388 90 383 C90 395 87 405 85 413 L77 413 C75 404 70 394 67 383 Z'),
  _Parte(_Vista.posterior, null,
      'M75 416 L86 416 C89 422 89 430 84 434 C79 436 75 433 73 429 C72 423 73 419 75 416 Z'),
];
