import 'package:flutter/material.dart';

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

// ─── Colores ─────────────────────────────────────────────────────────────────
const _kBodyBg     = Color(0xFF0D1B2A);
const _kBodyFill   = Color(0xFF1B2E42);
const _kBodyStroke = Color(0xFF2E4A63);
const _kMuscleBase = Color(0xFF1F3349);  // inactive muscle (visible outline)
const _kPrimary    = Color(0xFFE53935);
const _kSecondary  = Color(0xFFFF8F00);

class MuscleDiagram extends StatelessWidget {
  final List<String> principales;
  final List<String> secundarios;

  const MuscleDiagram({super.key, required this.principales, required this.secundarios});

  _MuscleState _state(String id) {
    if (principales.contains(id)) return _MuscleState.primary;
    if (secundarios.contains(id)) return _MuscleState.secondary;
    return _MuscleState.inactive;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          Expanded(
            child: Column(children: [
              Text('FRONTAL',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
                      letterSpacing: 1.6, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Expanded(child: _BodyView(
                state: _state, isFront: true,
              )),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(children: [
              Text('POSTERIOR',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
                      letterSpacing: 1.6, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Expanded(child: _BodyView(
                state: _state, isFront: false,
              )),
            ]),
          ),
        ],
      );
    });
  }
}

enum _MuscleState { inactive, primary, secondary }

class _BodyView extends StatelessWidget {
  final _MuscleState Function(String) state;
  final bool isFront;
  const _BodyView({required this.state, required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kBodyBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _BodyPainter(state: state, isFront: isFront),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _x(double v, double w) => v / 100 * w;
double _y(double v, double h) => v / 230 * h;

// Draw path with optional glow, then fill
void _drawMuscle(Canvas canvas, Path path, Color color,
    {double glowRadius = 10}) {
  // Glow
  canvas.drawPath(
    path,
    Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius)
      ..style = PaintingStyle.fill,
  );
  // Fill with subtle gradient
  final bounds = path.getBounds();
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.75)],
      ).createShader(bounds)
      ..style = PaintingStyle.fill,
  );
  // Thin stroke
  canvas.drawPath(
    path,
    Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8,
  );
}

void _drawMuscleInactive(Canvas canvas, Path path) {
  canvas.drawPath(path,
      Paint()..color = _kMuscleBase..style = PaintingStyle.fill);
  canvas.drawPath(path,
      Paint()
        ..color = _kBodyStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6);
}

void _drawLine(Canvas canvas, Paint p, List<Offset> pts) {
  if (pts.length < 2) return;
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (int i = 1; i < pts.length; i++) { path.lineTo(pts[i].dx, pts[i].dy); }
  canvas.drawPath(path, p);
}

// ─── Main Painter ──────────────────────────────────────────────────────────────
class _BodyPainter extends CustomPainter {
  final _MuscleState Function(String) state;
  final bool isFront;
  const _BodyPainter({required this.state, required this.isFront});

  Color _color(String id) {
    switch (state(id)) {
      case _MuscleState.primary:   return _kPrimary;
      case _MuscleState.secondary: return _kSecondary;
      case _MuscleState.inactive:  return Colors.transparent;
    }
  }

  bool _active(String id) => state(id) != _MuscleState.inactive;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Body silhouette ───────────────────────────────────────────────────
    final silhouette = _buildSilhouette(w, h);
    canvas.drawPath(silhouette,
        Paint()..color = _kBodyFill..style = PaintingStyle.fill);

    // ── Head ─────────────────────────────────────────────────────────────
    final headPaint = Paint()..color = _kBodyFill..style = PaintingStyle.fill;
    final headStroke = Paint()..color = _kBodyStroke
      ..style = PaintingStyle.stroke..strokeWidth = 0.8;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(_x(50, w), _y(11, h)),
            width: _x(19, w), height: _y(21, h)),
        headPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(_x(50, w), _y(11, h)),
            width: _x(19, w), height: _y(21, h)),
        headStroke);

    // Body stroke
    canvas.drawPath(silhouette,
        Paint()..color = _kBodyStroke..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);

    // ── Muscles ───────────────────────────────────────────────────────────
    if (isFront) {
      _paintFront(canvas, w, h);
    } else {
      _paintBack(canvas, w, h);
    }
  }

  // ─── SILHOUETTE ────────────────────────────────────────────────────────

  Path _buildSilhouette(double w, double h) {
    final p = Path();
    if (isFront) {
      // Left side going down
      p.moveTo(_x(44, w), _y(20, h));
      p.cubicTo(_x(41, w), _y(21, h), _x(30, w), _y(22, h), _x(25, w), _y(26, h));
      // Left shoulder curve
      p.cubicTo(_x(18, w), _y(29, h), _x(14, w), _y(34, h), _x(12, w), _y(42, h));
      // Left upper arm outer
      p.cubicTo(_x(10, w), _y(50, h), _x(10, w), _y(60, h), _x(11, w), _y(70, h));
      // Left elbow
      p.cubicTo(_x(12, w), _y(76, h), _x(13, w), _y(79, h), _x(14, w), _y(82, h));
      // Left forearm
      p.cubicTo(_x(13, w), _y(90, h), _x(13, w), _y(100, h), _x(14, w), _y(108, h));
      // Left wrist/hand
      p.cubicTo(_x(14, w), _y(113, h), _x(15, w), _y(116, h), _x(17, w), _y(117, h));
      p.cubicTo(_x(19, w), _y(116, h), _x(21, w), _y(113, h), _x(21, w), _y(108, h));
      // Left forearm inner
      p.cubicTo(_x(22, w), _y(100, h), _x(22, w), _y(90, h), _x(21, w), _y(82, h));
      // Left armpit
      p.cubicTo(_x(22, w), _y(78, h), _x(24, w), _y(75, h), _x(27, w), _y(74, h));
      // Torso left side
      p.cubicTo(_x(29, w), _y(70, h), _x(30, w), _y(65, h), _x(32, w), _y(62, h));
      p.cubicTo(_x(34, w), _y(58, h), _x(36, w), _y(58, h), _x(37, w), _y(62, h));
      // Left hip
      p.cubicTo(_x(37, w), _y(70, h), _x(35, w), _y(78, h), _x(33, w), _y(84, h));
      // Left thigh outer
      p.cubicTo(_x(29, w), _y(90, h), _x(26, w), _y(100, h), _x(26, w), _y(115, h));
      p.cubicTo(_x(26, w), _y(128, h), _x(28, w), _y(136, h), _x(30, w), _y(140, h));
      // Left knee
      p.cubicTo(_x(30, w), _y(144, h), _x(29, w), _y(148, h), _x(29, w), _y(152, h));
      // Left shin
      p.cubicTo(_x(29, w), _y(162, h), _x(30, w), _y(170, h), _x(31, w), _y(177, h));
      // Left foot
      p.cubicTo(_x(31, w), _y(181, h), _x(32, w), _y(184, h), _x(35, w), _y(185, h));
      p.cubicTo(_x(38, w), _y(186, h), _x(43, w), _y(186, h), _x(43, w), _y(183, h));
      p.cubicTo(_x(43, w), _y(180, h), _x(41, w), _y(177, h), _x(40, w), _y(172, h));
      // Left shin inner
      p.cubicTo(_x(39, w), _y(164, h), _x(38, w), _y(153, h), _x(38, w), _y(148, h));
      // Left inner knee
      p.cubicTo(_x(38, w), _y(143, h), _x(39, w), _y(138, h), _x(40, w), _y(134, h));
      // Crotch
      p.cubicTo(_x(42, w), _y(128, h), _x(45, w), _y(123, h), _x(50, w), _y(122, h));
      p.cubicTo(_x(55, w), _y(123, h), _x(58, w), _y(128, h), _x(60, w), _y(134, h));
      // Right inner knee
      p.cubicTo(_x(61, w), _y(138, h), _x(62, w), _y(143, h), _x(62, w), _y(148, h));
      // Right shin inner
      p.cubicTo(_x(62, w), _y(153, h), _x(61, w), _y(164, h), _x(60, w), _y(172, h));
      p.cubicTo(_x(59, w), _y(177, h), _x(57, w), _y(180, h), _x(57, w), _y(183, h));
      // Right foot
      p.cubicTo(_x(57, w), _y(186, h), _x(62, w), _y(186, h), _x(65, w), _y(185, h));
      p.cubicTo(_x(68, w), _y(184, h), _x(69, w), _y(181, h), _x(69, w), _y(177, h));
      // Right shin outer
      p.cubicTo(_x(70, w), _y(170, h), _x(71, w), _y(162, h), _x(71, w), _y(152, h));
      p.cubicTo(_x(71, w), _y(148, h), _x(70, w), _y(144, h), _x(70, w), _y(140, h));
      // Right knee
      p.cubicTo(_x(72, w), _y(136, h), _x(74, w), _y(128, h), _x(74, w), _y(115, h));
      p.cubicTo(_x(74, w), _y(100, h), _x(71, w), _y(90, h), _x(67, w), _y(84, h));
      // Right hip
      p.cubicTo(_x(65, w), _y(78, h), _x(63, w), _y(70, h), _x(63, w), _y(62, h));
      p.cubicTo(_x(64, w), _y(58, h), _x(66, w), _y(58, h), _x(68, w), _y(62, h));
      p.cubicTo(_x(70, w), _y(65, h), _x(71, w), _y(70, h), _x(73, w), _y(74, h));
      // Right armpit
      p.cubicTo(_x(76, w), _y(75, h), _x(78, w), _y(78, h), _x(79, w), _y(82, h));
      // Right forearm inner
      p.cubicTo(_x(78, w), _y(90, h), _x(78, w), _y(100, h), _x(79, w), _y(108, h));
      p.cubicTo(_x(79, w), _y(113, h), _x(81, w), _y(116, h), _x(83, w), _y(117, h));
      p.cubicTo(_x(85, w), _y(116, h), _x(86, w), _y(113, h), _x(86, w), _y(108, h));
      // Right wrist going up
      p.cubicTo(_x(87, w), _y(100, h), _x(87, w), _y(90, h), _x(86, w), _y(82, h));
      // Right elbow
      p.cubicTo(_x(87, w), _y(79, h), _x(88, w), _y(76, h), _x(89, w), _y(70, h));
      // Right upper arm outer
      p.cubicTo(_x(90, w), _y(60, h), _x(90, w), _y(50, h), _x(88, w), _y(42, h));
      // Right shoulder
      p.cubicTo(_x(86, w), _y(34, h), _x(82, w), _y(29, h), _x(75, w), _y(26, h));
      p.cubicTo(_x(70, w), _y(22, h), _x(59, w), _y(21, h), _x(56, w), _y(20, h));
      p.close();
    } else {
      // Back silhouette (same outer shape, slightly different torso)
      p.moveTo(_x(44, w), _y(20, h));
      p.cubicTo(_x(41, w), _y(21, h), _x(30, w), _y(22, h), _x(25, w), _y(26, h));
      p.cubicTo(_x(18, w), _y(29, h), _x(14, w), _y(34, h), _x(12, w), _y(42, h));
      p.cubicTo(_x(10, w), _y(50, h), _x(10, w), _y(60, h), _x(11, w), _y(70, h));
      p.cubicTo(_x(12, w), _y(76, h), _x(13, w), _y(79, h), _x(14, w), _y(82, h));
      p.cubicTo(_x(13, w), _y(90, h), _x(13, w), _y(100, h), _x(14, w), _y(108, h));
      p.cubicTo(_x(14, w), _y(113, h), _x(15, w), _y(116, h), _x(17, w), _y(117, h));
      p.cubicTo(_x(19, w), _y(116, h), _x(21, w), _y(113, h), _x(21, w), _y(108, h));
      p.cubicTo(_x(22, w), _y(100, h), _x(22, w), _y(90, h), _x(21, w), _y(82, h));
      p.cubicTo(_x(22, w), _y(78, h), _x(24, w), _y(75, h), _x(27, w), _y(74, h));
      p.cubicTo(_x(29, w), _y(70, h), _x(30, w), _y(65, h), _x(32, w), _y(62, h));
      p.cubicTo(_x(34, w), _y(58, h), _x(36, w), _y(58, h), _x(37, w), _y(62, h));
      p.cubicTo(_x(37, w), _y(70, h), _x(35, w), _y(78, h), _x(33, w), _y(84, h));
      p.cubicTo(_x(29, w), _y(90, h), _x(26, w), _y(100, h), _x(26, w), _y(115, h));
      p.cubicTo(_x(26, w), _y(128, h), _x(28, w), _y(136, h), _x(30, w), _y(140, h));
      p.cubicTo(_x(30, w), _y(144, h), _x(29, w), _y(148, h), _x(29, w), _y(152, h));
      p.cubicTo(_x(29, w), _y(162, h), _x(30, w), _y(170, h), _x(31, w), _y(177, h));
      p.cubicTo(_x(31, w), _y(181, h), _x(32, w), _y(184, h), _x(35, w), _y(185, h));
      p.cubicTo(_x(38, w), _y(186, h), _x(43, w), _y(186, h), _x(43, w), _y(183, h));
      p.cubicTo(_x(43, w), _y(180, h), _x(41, w), _y(177, h), _x(40, w), _y(172, h));
      p.cubicTo(_x(39, w), _y(164, h), _x(38, w), _y(153, h), _x(38, w), _y(148, h));
      p.cubicTo(_x(38, w), _y(143, h), _x(39, w), _y(138, h), _x(40, w), _y(134, h));
      p.cubicTo(_x(42, w), _y(128, h), _x(45, w), _y(123, h), _x(50, w), _y(122, h));
      p.cubicTo(_x(55, w), _y(123, h), _x(58, w), _y(128, h), _x(60, w), _y(134, h));
      p.cubicTo(_x(61, w), _y(138, h), _x(62, w), _y(143, h), _x(62, w), _y(148, h));
      p.cubicTo(_x(62, w), _y(153, h), _x(61, w), _y(164, h), _x(60, w), _y(172, h));
      p.cubicTo(_x(59, w), _y(177, h), _x(57, w), _y(180, h), _x(57, w), _y(183, h));
      p.cubicTo(_x(57, w), _y(186, h), _x(62, w), _y(186, h), _x(65, w), _y(185, h));
      p.cubicTo(_x(68, w), _y(184, h), _x(69, w), _y(181, h), _x(69, w), _y(177, h));
      p.cubicTo(_x(70, w), _y(170, h), _x(71, w), _y(162, h), _x(71, w), _y(152, h));
      p.cubicTo(_x(71, w), _y(148, h), _x(70, w), _y(144, h), _x(70, w), _y(140, h));
      p.cubicTo(_x(72, w), _y(136, h), _x(74, w), _y(128, h), _x(74, w), _y(115, h));
      p.cubicTo(_x(74, w), _y(100, h), _x(71, w), _y(90, h), _x(67, w), _y(84, h));
      p.cubicTo(_x(65, w), _y(78, h), _x(63, w), _y(70, h), _x(63, w), _y(62, h));
      p.cubicTo(_x(64, w), _y(58, h), _x(66, w), _y(58, h), _x(68, w), _y(62, h));
      p.cubicTo(_x(70, w), _y(65, h), _x(71, w), _y(70, h), _x(73, w), _y(74, h));
      p.cubicTo(_x(76, w), _y(75, h), _x(78, w), _y(78, h), _x(79, w), _y(82, h));
      p.cubicTo(_x(78, w), _y(90, h), _x(78, w), _y(100, h), _x(79, w), _y(108, h));
      p.cubicTo(_x(79, w), _y(113, h), _x(81, w), _y(116, h), _x(83, w), _y(117, h));
      p.cubicTo(_x(85, w), _y(116, h), _x(86, w), _y(113, h), _x(86, w), _y(108, h));
      p.cubicTo(_x(87, w), _y(100, h), _x(87, w), _y(90, h), _x(86, w), _y(82, h));
      p.cubicTo(_x(87, w), _y(79, h), _x(88, w), _y(76, h), _x(89, w), _y(70, h));
      p.cubicTo(_x(90, w), _y(60, h), _x(90, w), _y(50, h), _x(88, w), _y(42, h));
      p.cubicTo(_x(86, w), _y(34, h), _x(82, w), _y(29, h), _x(75, w), _y(26, h));
      p.cubicTo(_x(70, w), _y(22, h), _x(59, w), _y(21, h), _x(56, w), _y(20, h));
      p.close();
    }
    return p;
  }

  // ─── FRONT MUSCLES ────────────────────────────────────────────────────────

  void _paintFront(Canvas canvas, double w, double h) {
    final linePaint = Paint()
      ..color = _kBodyStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // ── Pecho ────────────────────────────────────────────────────────────
    final pecL = Path()
      ..moveTo(_x(47, w), _y(56, h))
      ..cubicTo(_x(47, w), _y(48, h), _x(43, w), _y(36, h), _x(35, w), _y(29, h))
      ..cubicTo(_x(30, w), _y(26, h), _x(25, w), _y(27, h), _x(24, w), _y(31, h))
      ..cubicTo(_x(23, w), _y(36, h), _x(24, w), _y(43, h), _x(27, w), _y(48, h))
      ..cubicTo(_x(31, w), _y(54, h), _x(40, w), _y(57, h), _x(47, w), _y(56, h))
      ..close();
    final pecR = _mirrorPath(pecL, w);

    // ── Deltoides ─────────────────────────────────────────────────────────
    final deltL = Path()
      ..moveTo(_x(26, w), _y(28, h))
      ..cubicTo(_x(21, w), _y(29, h), _x(17, w), _y(33, h), _x(16, w), _y(39, h))
      ..cubicTo(_x(15, w), _y(44, h), _x(17, w), _y(49, h), _x(21, w), _y(49, h))
      ..cubicTo(_x(25, w), _y(48, h), _x(28, w), _y(43, h), _x(29, w), _y(37, h))
      ..cubicTo(_x(30, w), _y(32, h), _x(28, w), _y(28, h), _x(26, w), _y(28, h))
      ..close();
    final deltR = _mirrorPath(deltL, w);

    // ── Bíceps ────────────────────────────────────────────────────────────
    final bicL = Path()
      ..moveTo(_x(21, w), _y(49, h))
      ..cubicTo(_x(17, w), _y(51, h), _x(14, w), _y(58, h), _x(14, w), _y(65, h))
      ..cubicTo(_x(14, w), _y(71, h), _x(16, w), _y(75, h), _x(19, w), _y(74, h))
      ..cubicTo(_x(23, w), _y(73, h), _x(25, w), _y(67, h), _x(25, w), _y(60, h))
      ..cubicTo(_x(25, w), _y(53, h), _x(23, w), _y(49, h), _x(21, w), _y(49, h))
      ..close();
    final bicR = _mirrorPath(bicL, w);

    // ── Abdominales ───────────────────────────────────────────────────────
    final abs = <Path>[];
    for (int row = 0; row < 3; row++) {
      final y0 = 40.0 + row * 8;
      abs.add(Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(_x(42, w), _y(y0, h), _x(7, w), _y(6.5, h)),
            Radius.circular(_x(1.5, w)))));
      abs.add(Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(_x(51, w), _y(y0, h), _x(7, w), _y(6.5, h)),
            Radius.circular(_x(1.5, w)))));
    }

    // ── Obliques ──────────────────────────────────────────────────────────
    final oblL = Path()
      ..moveTo(_x(36, w), _y(42, h))
      ..cubicTo(_x(34, w), _y(48, h), _x(33, w), _y(55, h), _x(35, w), _y(62, h))
      ..cubicTo(_x(37, w), _y(64, h), _x(40, w), _y(63, h), _x(41, w), _y(59, h))
      ..cubicTo(_x(42, w), _y(53, h), _x(42, w), _y(46, h), _x(41, w), _y(42, h))
      ..cubicTo(_x(40, w), _y(40, h), _x(37, w), _y(40, h), _x(36, w), _y(42, h))
      ..close();
    final oblR = _mirrorPath(oblL, w);

    // ── Cuádriceps ────────────────────────────────────────────────────────
    // Vastus lateralis
    final quadLatL = Path()
      ..moveTo(_x(30, w), _y(92, h))
      ..cubicTo(_x(26, w), _y(100, h), _x(25, w), _y(116, h), _x(27, w), _y(128, h))
      ..cubicTo(_x(29, w), _y(134, h), _x(33, w), _y(136, h), _x(36, w), _y(133, h))
      ..cubicTo(_x(39, w), _y(122, h), _x(39, w), _y(106, h), _x(37, w), _y(93, h))
      ..cubicTo(_x(35, w), _y(89, h), _x(32, w), _y(89, h), _x(30, w), _y(92, h))
      ..close();
    // Rectus femoris (center)
    final quadRecL = Path()
      ..moveTo(_x(37, w), _y(89, h))
      ..cubicTo(_x(35, w), _y(95, h), _x(35, w), _y(115, h), _x(37, w), _y(130, h))
      ..cubicTo(_x(38, w), _y(134, h), _x(41, w), _y(135, h), _x(43, w), _y(131, h))
      ..cubicTo(_x(45, w), _y(119, h), _x(44, w), _y(100, h), _x(42, w), _y(89, h))
      ..cubicTo(_x(41, w), _y(87, h), _x(38, w), _y(87, h), _x(37, w), _y(89, h))
      ..close();
    // Vastus medialis (inner teardrop, lower)
    final quadMedL = Path()
      ..moveTo(_x(43, w), _y(120, h))
      ..cubicTo(_x(41, w), _y(126, h), _x(42, w), _y(134, h), _x(45, w), _y(136, h))
      ..cubicTo(_x(47, w), _y(137, h), _x(49, w), _y(135, h), _x(50, w), _y(130, h))
      ..cubicTo(_x(50, w), _y(124, h), _x(48, w), _y(119, h), _x(45, w), _y(119, h))
      ..cubicTo(_x(43.5, w), _y(119, h), _x(43, w), _y(119.5, h), _x(43, w), _y(120, h))
      ..close();

    final quadLatR = _mirrorPath(quadLatL, w);
    final quadRecR = _mirrorPath(quadRecL, w);
    final quadMedR = _mirrorPath(quadMedL, w);

    // ── Gemelos (tibialis visible from front) ──────────────────────────────
    final tibL = Path()
      ..moveTo(_x(29, w), _y(147, h))
      ..cubicTo(_x(27, w), _y(156, h), _x(28, w), _y(166, h), _x(30, w), _y(173, h))
      ..cubicTo(_x(31, w), _y(177, h), _x(34, w), _y(178, h), _x(36, w), _y(175, h))
      ..cubicTo(_x(38, w), _y(168, h), _x(38, w), _y(157, h), _x(37, w), _y(148, h))
      ..cubicTo(_x(36, w), _y(144, h), _x(33, w), _y(143, h), _x(31, w), _y(145, h))
      ..cubicTo(_x(30, w), _y(146, h), _x(29, w), _y(146.5, h), _x(29, w), _y(147, h))
      ..close();
    final tibR = _mirrorPath(tibL, w);

    // ── Draw all ──────────────────────────────────────────────────────────
    final muscles = {
      'pecho':       [pecL, pecR],
      'deltoides':   [deltL, deltR],
      'biceps':      [bicL, bicR],
      'abdominales': abs,
      'obliques_':   [oblL, oblR],  // obliques share "core" id
      'cuadriceps':  [quadLatL, quadRecL, quadMedL, quadLatR, quadRecR, quadMedR],
      'gemelos':     [tibL, tibR],
    };

    // Map obliques to core id
    final idMap = {
      'pecho': 'pecho',
      'deltoides': 'deltoides',
      'biceps': 'biceps',
      'abdominales': 'abdominales',
      'obliques_': 'core',
      'cuadriceps': 'cuadriceps',
      'gemelos': 'gemelos',
    };

    for (final entry in muscles.entries) {
      final muscleId = idMap[entry.key] ?? entry.key;
      for (final path in entry.value) {
        if (_active(muscleId)) {
          _drawMuscle(canvas, path, _color(muscleId));
        } else {
          _drawMuscleInactive(canvas, path);
        }
      }
    }

    // ── Definition lines ──────────────────────────────────────────────────
    // Pec split (sternum line)
    _drawLine(canvas, linePaint, [
      Offset(_x(50, w), _y(28, h)),
      Offset(_x(50, w), _y(58, h)),
    ]);
    // Ab lines (linea alba + horizontal)
    for (int i = 1; i <= 3; i++) {
      _drawLine(canvas, linePaint, [
        Offset(_x(42, w), _y(40 + (i - 1) * 8.0, h)),
        Offset(_x(58, w), _y(40 + (i - 1) * 8.0, h)),
      ]);
    }
    _drawLine(canvas, linePaint, [
      Offset(_x(50, w), _y(40, h)),
      Offset(_x(50, w), _y(66, h)),
    ]);
  }

  // ─── BACK MUSCLES ─────────────────────────────────────────────────────────

  void _paintBack(Canvas canvas, double w, double h) {
    final linePaint = Paint()
      ..color = _kBodyStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // ── Trapecio ────────────────────────────────────────────────────────
    final trap = Path()
      ..moveTo(_x(50, w), _y(23, h))
      ..cubicTo(_x(55, w), _y(24, h), _x(65, w), _y(27, h), _x(72, w), _y(30, h))
      ..cubicTo(_x(76, w), _y(33, h), _x(76, w), _y(38, h), _x(72, w), _y(42, h))
      ..cubicTo(_x(66, w), _y(46, h), _x(58, w), _y(46, h), _x(52, w), _y(52, h))
      ..cubicTo(_x(51, w), _y(54, h), _x(50, w), _y(56, h), _x(50, w), _y(58, h))
      ..cubicTo(_x(50, w), _y(56, h), _x(49, w), _y(54, h), _x(48, w), _y(52, h))
      ..cubicTo(_x(42, w), _y(46, h), _x(34, w), _y(46, h), _x(28, w), _y(42, h))
      ..cubicTo(_x(24, w), _y(38, h), _x(24, w), _y(33, h), _x(28, w), _y(30, h))
      ..cubicTo(_x(35, w), _y(27, h), _x(45, w), _y(24, h), _x(50, w), _y(23, h))
      ..close();

    // ── Deltoides posterior ────────────────────────────────────────────────
    final deltL = Path()
      ..moveTo(_x(24, w), _y(28, h))
      ..cubicTo(_x(19, w), _y(30, h), _x(15, w), _y(35, h), _x(15, w), _y(41, h))
      ..cubicTo(_x(15, w), _y(46, h), _x(17, w), _y(50, h), _x(21, w), _y(50, h))
      ..cubicTo(_x(25, w), _y(49, h), _x(28, w), _y(44, h), _x(28, w), _y(38, h))
      ..cubicTo(_x(28, w), _y(32, h), _x(26, w), _y(28, h), _x(24, w), _y(28, h))
      ..close();
    final deltR = _mirrorPath(deltL, w);

    // ── Dorsales ──────────────────────────────────────────────────────────
    final latL = Path()
      ..moveTo(_x(30, w), _y(38, h))
      ..cubicTo(_x(24, w), _y(45, h), _x(22, w), _y(54, h), _x(24, w), _y(62, h))
      ..cubicTo(_x(26, w), _y(68, h), _x(32, w), _y(70, h), _x(38, w), _y(68, h))
      ..cubicTo(_x(42, w), _y(64, h), _x(44, w), _y(56, h), _x(44, w), _y(46, h))
      ..cubicTo(_x(44, w), _y(40, h), _x(42, w), _y(36, h), _x(38, w), _y(35, h))
      ..cubicTo(_x(35, w), _y(34, h), _x(32, w), _y(35, h), _x(30, w), _y(38, h))
      ..close();
    final latR = _mirrorPath(latL, w);

    // ── Tríceps ───────────────────────────────────────────────────────────
    final triL = Path()
      ..moveTo(_x(22, w), _y(49, h))
      ..cubicTo(_x(18, w), _y(52, h), _x(14, w), _y(60, h), _x(14, w), _y(68, h))
      ..cubicTo(_x(14, w), _y(73, h), _x(16, w), _y(76, h), _x(19, w), _y(75, h))
      ..cubicTo(_x(23, w), _y(74, h), _x(26, w), _y(68, h), _x(25, w), _y(60, h))
      ..cubicTo(_x(25, w), _y(53, h), _x(24, w), _y(49, h), _x(22, w), _y(49, h))
      ..close();
    final triR = _mirrorPath(triL, w);

    // ── Core / Lumbar (erector spinae) ────────────────────────────────────
    final lumL = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(_x(43, w), _y(56, h), _x(5, w), _y(16, h)),
          Radius.circular(_x(2.5, w))));
    final lumR = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(_x(52, w), _y(56, h), _x(5, w), _y(16, h)),
          Radius.circular(_x(2.5, w))));

    // ── Glúteos ────────────────────────────────────────────────────────────
    final glutL = Path()
      ..moveTo(_x(33, w), _y(76, h))
      ..cubicTo(_x(27, w), _y(79, h), _x(25, w), _y(86, h), _x(27, w), _y(94, h))
      ..cubicTo(_x(29, w), _y(100, h), _x(35, w), _y(103, h), _x(42, w), _y(101, h))
      ..cubicTo(_x(47, w), _y(99, h), _x(50, w), _y(94, h), _x(49, w), _y(86, h))
      ..cubicTo(_x(48, w), _y(79, h), _x(43, w), _y(75, h), _x(38, w), _y(75, h))
      ..cubicTo(_x(36, w), _y(75, h), _x(34, w), _y(75.5, h), _x(33, w), _y(76, h))
      ..close();
    final glutR = _mirrorPath(glutL, w);

    // ── Isquiotibiales ─────────────────────────────────────────────────────
    final hamL = Path()
      ..moveTo(_x(29, w), _y(102, h))
      ..cubicTo(_x(25, w), _y(110, h), _x(24, w), _y(122, h), _x(26, w), _y(133, h))
      ..cubicTo(_x(28, w), _y(139, h), _x(33, w), _y(141, h), _x(37, w), _y(138, h))
      ..cubicTo(_x(41, w), _y(132, h), _x(42, w), _y(118, h), _x(40, w), _y(104, h))
      ..cubicTo(_x(38, w), _y(100, h), _x(33, w), _y(100, h), _x(30, w), _y(102, h))
      ..cubicTo(_x(29.5, w), _y(102, h), _x(29, w), _y(102, h), _x(29, w), _y(102, h))
      ..close();
    final hamR = _mirrorPath(hamL, w);

    // ── Gemelos ────────────────────────────────────────────────────────────
    // Gastrocnemius medial head
    final calvML = Path()
      ..moveTo(_x(31, w), _y(146, h))
      ..cubicTo(_x(29, w), _y(154, h), _x(29, w), _y(164, h), _x(31, w), _y(172, h))
      ..cubicTo(_x(32, w), _y(176, h), _x(35, w), _y(177, h), _x(37, w), _y(174, h))
      ..cubicTo(_x(39, w), _y(168, h), _x(39, w), _y(158, h), _x(37, w), _y(149, h))
      ..cubicTo(_x(36, w), _y(145, h), _x(33, w), _y(144, h), _x(31, w), _y(146, h))
      ..close();
    // Gastrocnemius lateral head (slightly outer)
    final calvLL = Path()
      ..moveTo(_x(27, w), _y(143, h))
      ..cubicTo(_x(25, w), _y(151, h), _x(25, w), _y(162, h), _x(27, w), _y(170, h))
      ..cubicTo(_x(28, w), _y(174, h), _x(31, w), _y(175, h), _x(33, w), _y(172, h))
      ..cubicTo(_x(31, w), _y(164, h), _x(31, w), _y(154, h), _x(32, w), _y(146, h))
      ..cubicTo(_x(30, w), _y(141, h), _x(28, w), _y(141, h), _x(27, w), _y(143, h))
      ..close();
    final calvMR = _mirrorPath(calvML, w);
    final calvLR = _mirrorPath(calvLL, w);

    // ── Draw ──────────────────────────────────────────────────────────────
    final muscleSets = <String, List<Path>>{
      'trapecio':       [trap],
      'deltoides':      [deltL, deltR],
      'dorsales':       [latL, latR],
      'triceps':        [triL, triR],
      'core':           [lumL, lumR],
      'gluteos':        [glutL, glutR],
      'isquiotibiales': [hamL, hamR],
      'gemelos':        [calvML, calvLL, calvMR, calvLR],
    };

    for (final entry in muscleSets.entries) {
      for (final path in entry.value) {
        if (_active(entry.key)) {
          _drawMuscle(canvas, path, _color(entry.key));
        } else {
          _drawMuscleInactive(canvas, path);
        }
      }
    }

    // ── Definition lines ──────────────────────────────────────────────────
    // Spine line
    _drawLine(canvas, linePaint, [
      Offset(_x(50, w), _y(23, h)),
      Offset(_x(50, w), _y(74, h)),
    ]);
    // Shoulder blade hints
    _drawLine(canvas, linePaint, [
      Offset(_x(36, w), _y(34, h)), Offset(_x(44, w), _y(44, h)),
    ]);
    _drawLine(canvas, linePaint, [
      Offset(_x(64, w), _y(34, h)), Offset(_x(56, w), _y(44, h)),
    ]);
  }

  // ─── Mirror helper ─────────────────────────────────────────────────────────
  Path _mirrorPath(Path original, double w) {
    final m = Matrix4.identity()
      ..translateByDouble(w, 0.0, 0.0, 1.0)
      ..scaleByDouble(-1.0, 1.0, 1.0, 1.0);
    return original.transform(m.storage);
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.isFront != isFront;
}
