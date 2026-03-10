import 'package:flutter/material.dart';

const List<Map<String, dynamic>> todosLosMusculosInfo = [
  {'id': 'pecho', 'label': 'Pecho'},
  {'id': 'deltoides', 'label': 'Deltoides'},
  {'id': 'biceps', 'label': 'Bíceps'},
  {'id': 'triceps', 'label': 'Tríceps'},
  {'id': 'abdominales', 'label': 'Abdominales'},
  {'id': 'dorsales', 'label': 'Dorsales'},
  {'id': 'trapecio', 'label': 'Trapecio'},
  {'id': 'core', 'label': 'Core'},
  {'id': 'cuadriceps', 'label': 'Cuádriceps'},
  {'id': 'gluteos', 'label': 'Glúteos'},
  {'id': 'isquiotibiales', 'label': 'Isquiotibiales'},
  {'id': 'gemelos', 'label': 'Gemelos'},
];

class MuscleDiagram extends StatelessWidget {
  final List<String> principales;
  final List<String> secundarios;

  const MuscleDiagram({
    super.key,
    required this.principales,
    required this.secundarios,
  });

  Color _getColor(String id) {
    if (principales.contains(id)) return const Color(0xFFEF4444).withOpacity(0.75);
    if (secundarios.contains(id)) return const Color(0xFFF97316).withOpacity(0.75);
    return Colors.white.withOpacity(0.12);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('FRONTAL', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              Expanded(child: _SilhouetteFront(getColor: _getColor)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text('TRASERA', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              Expanded(child: _SilhouetteBack(getColor: _getColor)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── SILUETA FRONTAL ────────────────────────────────────────────────────────

class _SilhouetteFront extends StatelessWidget {
  final Color Function(String) getColor;
  const _SilhouetteFront({required this.getColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FrontPainter(getColor: getColor),
      child: const SizedBox.expand(),
    );
  }
}

class _FrontPainter extends CustomPainter {
  final Color Function(String) getColor;
  const _FrontPainter({required this.getColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Función helper para escalar coordenadas del viewBox 100x200
    Offset s(double x, double y) => Offset(x / 100 * w, y / 200 * h);
    double sx(double x) => x / 100 * w;
    double sy(double y) => y / 200 * h;

    final bodyPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // ── Cuerpo base ──
    // Cabeza
    canvas.drawOval(Rect.fromCenter(center: s(50, 10), width: sx(18), height: sy(20)), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: s(50, 10), width: sx(18), height: sy(20)), outlinePaint);

    // Cuello
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(sx(46), sy(18), sx(8), sy(5)), const Radius.circular(2));
    canvas.drawRRect(neck, bodyPaint);

    // Torso
    final torsoPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final torsoPath = Path()
      ..moveTo(sx(30), sy(23))
      ..quadraticBezierTo(sx(20), sy(25), sx(18), sy(45))
      ..lineTo(sx(20), sy(65))
      ..quadraticBezierTo(sx(30), sy(68), sx(50), sy(68))
      ..quadraticBezierTo(sx(70), sy(68), sx(80), sy(65))
      ..lineTo(sx(82), sy(45))
      ..quadraticBezierTo(sx(80), sy(25), sx(70), sy(23))
      ..close();
    canvas.drawPath(torsoPath, torsoPaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // Brazo izquierdo
    final leftArm = Path()
      ..moveTo(sx(30), sy(23))
      ..quadraticBezierTo(sx(18), sy(28), sx(15), sy(38))
      ..quadraticBezierTo(sx(13), sy(48), sx(14), sy(58))
      ..quadraticBezierTo(sx(16), sy(62), sx(20), sy(60))
      ..quadraticBezierTo(sx(22), sy(50), sx(24), sy(40))
      ..lineTo(sx(28), sy(28))
      ..close();
    canvas.drawPath(leftArm, bodyPaint);
    canvas.drawPath(leftArm, outlinePaint);

    // Antebrazo izquierdo
    final leftForearm = Path()
      ..moveTo(sx(14), sy(58))
      ..quadraticBezierTo(sx(12), sy(68), sx(13), sy(76))
      ..quadraticBezierTo(sx(14), sy(80), sx(17), sy(79))
      ..quadraticBezierTo(sx(19), sy(71), sx(20), sy(62))
      ..close();
    canvas.drawPath(leftForearm, bodyPaint);
    canvas.drawPath(leftForearm, outlinePaint);

    // Brazo derecho
    final rightArm = Path()
      ..moveTo(sx(70), sy(23))
      ..quadraticBezierTo(sx(82), sy(28), sx(85), sy(38))
      ..quadraticBezierTo(sx(87), sy(48), sx(86), sy(58))
      ..quadraticBezierTo(sx(84), sy(62), sx(80), sy(60))
      ..quadraticBezierTo(sx(78), sy(50), sx(76), sy(40))
      ..lineTo(sx(72), sy(28))
      ..close();
    canvas.drawPath(rightArm, bodyPaint);
    canvas.drawPath(rightArm, outlinePaint);

    // Antebrazo derecho
    final rightForearm = Path()
      ..moveTo(sx(86), sy(58))
      ..quadraticBezierTo(sx(88), sy(68), sx(87), sy(76))
      ..quadraticBezierTo(sx(86), sy(80), sx(83), sy(79))
      ..quadraticBezierTo(sx(81), sy(71), sx(80), sy(62))
      ..close();
    canvas.drawPath(rightForearm, bodyPaint);
    canvas.drawPath(rightForearm, outlinePaint);

    // Pierna izquierda
    final leftLeg = Path()
      ..moveTo(sx(34), sy(68))
      ..quadraticBezierTo(sx(28), sy(72), sx(26), sy(90))
      ..quadraticBezierTo(sx(24), sy(108), sx(26), sy(118))
      ..quadraticBezierTo(sx(30), sy(122), sx(35), sy(120))
      ..quadraticBezierTo(sx(38), sy(108), sx(40), sy(90))
      ..lineTo(sx(42), sy(70))
      ..close();
    canvas.drawPath(leftLeg, bodyPaint);
    canvas.drawPath(leftLeg, outlinePaint);

    // Espinilla izquierda
    final leftShin = Path()
      ..moveTo(sx(26), sy(118))
      ..quadraticBezierTo(sx(24), sy(132), sx(25), sy(148))
      ..quadraticBezierTo(sx(26), sy(154), sx(30), sy(153))
      ..quadraticBezierTo(sx(33), sy(148), sx(34), sy(134))
      ..quadraticBezierTo(sx(35), sy(124), sx(35), sy(120))
      ..close();
    canvas.drawPath(leftShin, bodyPaint);
    canvas.drawPath(leftShin, outlinePaint);

    // Pierna derecha
    final rightLeg = Path()
      ..moveTo(sx(66), sy(68))
      ..quadraticBezierTo(sx(72), sy(72), sx(74), sy(90))
      ..quadraticBezierTo(sx(76), sy(108), sx(74), sy(118))
      ..quadraticBezierTo(sx(70), sy(122), sx(65), sy(120))
      ..quadraticBezierTo(sx(62), sy(108), sx(60), sy(90))
      ..lineTo(sx(58), sy(70))
      ..close();
    canvas.drawPath(rightLeg, bodyPaint);
    canvas.drawPath(rightLeg, outlinePaint);

    // Espinilla derecha
    final rightShin = Path()
      ..moveTo(sx(74), sy(118))
      ..quadraticBezierTo(sx(76), sy(132), sx(75), sy(148))
      ..quadraticBezierTo(sx(74), sy(154), sx(70), sy(153))
      ..quadraticBezierTo(sx(67), sy(148), sx(66), sy(134))
      ..quadraticBezierTo(sx(65), sy(124), sx(65), sy(120))
      ..close();
    canvas.drawPath(rightShin, bodyPaint);
    canvas.drawPath(rightShin, outlinePaint);

    // Pies
    canvas.drawOval(Rect.fromCenter(center: s(27, 155), width: sx(12), height: sy(6)), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: s(73, 155), width: sx(12), height: sy(6)), bodyPaint);

    // ── Músculos ──
    final musclePaint = Paint()..style = PaintingStyle.fill;

    // Pecho
    musclePaint.color = getColor('pecho');
    canvas.drawOval(Rect.fromCenter(center: s(42, 32), width: sx(20), height: sy(14)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(58, 32), width: sx(20), height: sy(14)), musclePaint);

    // Deltoides
    musclePaint.color = getColor('deltoides');
    canvas.drawOval(Rect.fromCenter(center: s(27, 27), width: sx(12), height: sy(10)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(73, 27), width: sx(12), height: sy(10)), musclePaint);

    // Bíceps
    musclePaint.color = getColor('biceps');
    _drawRotatedOval(canvas, s(17, 38), sx(8), sy(16), -0.17, musclePaint);
    _drawRotatedOval(canvas, s(83, 38), sx(8), sy(16), 0.17, musclePaint);

    // Abdominales (6 rectángulos)
    musclePaint.color = getColor('abdominales');
    for (int row = 0; row < 3; row++) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(43), sy(36 + row * 7), sx(6), sy(5)), const Radius.circular(2)), musclePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(51), sy(36 + row * 7), sx(6), sy(5)), const Radius.circular(2)), musclePaint);
    }

    // Cuádriceps
    musclePaint.color = getColor('cuadriceps');
    canvas.drawOval(Rect.fromCenter(center: s(34, 88), width: sx(14), height: sy(32)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(66, 88), width: sx(14), height: sy(32)), musclePaint);

    // Gemelos
    musclePaint.color = getColor('gemelos');
    canvas.drawOval(Rect.fromCenter(center: s(28, 133), width: sx(10), height: sy(20)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(72, 133), width: sx(10), height: sy(20)), musclePaint);
  }

  void _drawRotatedOval(Canvas canvas, Offset center, double width, double height, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: width, height: height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FrontPainter oldDelegate) => true;
}

// ─── SILUETA TRASERA ─────────────────────────────────────────────────────────

class _SilhouetteBack extends StatelessWidget {
  final Color Function(String) getColor;
  const _SilhouetteBack({required this.getColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackPainter(getColor: getColor),
      child: const SizedBox.expand(),
    );
  }
}

class _BackPainter extends CustomPainter {
  final Color Function(String) getColor;
  const _BackPainter({required this.getColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    Offset s(double x, double y) => Offset(x / 100 * w, y / 200 * h);
    double sx(double x) => x / 100 * w;
    double sy(double y) => y / 200 * h;

    final bodyPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // ── Cuerpo base (igual que frontal) ──
    canvas.drawOval(Rect.fromCenter(center: s(50, 10), width: sx(18), height: sy(20)), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: s(50, 10), width: sx(18), height: sy(20)), outlinePaint);

    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(sx(46), sy(18), sx(8), sy(5)), const Radius.circular(2));
    canvas.drawRRect(neck, bodyPaint);

    final torsoPath = Path()
      ..moveTo(sx(30), sy(23))
      ..quadraticBezierTo(sx(20), sy(25), sx(18), sy(45))
      ..lineTo(sx(20), sy(65))
      ..quadraticBezierTo(sx(30), sy(68), sx(50), sy(68))
      ..quadraticBezierTo(sx(70), sy(68), sx(80), sy(65))
      ..lineTo(sx(82), sy(45))
      ..quadraticBezierTo(sx(80), sy(25), sx(70), sy(23))
      ..close();
    canvas.drawPath(torsoPath, bodyPaint);
    canvas.drawPath(torsoPath, outlinePaint);

    final leftArm = Path()
      ..moveTo(sx(30), sy(23))
      ..quadraticBezierTo(sx(18), sy(28), sx(15), sy(38))
      ..quadraticBezierTo(sx(13), sy(48), sx(14), sy(58))
      ..quadraticBezierTo(sx(16), sy(62), sx(20), sy(60))
      ..quadraticBezierTo(sx(22), sy(50), sx(24), sy(40))
      ..lineTo(sx(28), sy(28))
      ..close();
    canvas.drawPath(leftArm, bodyPaint);
    canvas.drawPath(leftArm, outlinePaint);

    final leftForearm = Path()
      ..moveTo(sx(14), sy(58))
      ..quadraticBezierTo(sx(12), sy(68), sx(13), sy(76))
      ..quadraticBezierTo(sx(14), sy(80), sx(17), sy(79))
      ..quadraticBezierTo(sx(19), sy(71), sx(20), sy(62))
      ..close();
    canvas.drawPath(leftForearm, bodyPaint);
    canvas.drawPath(leftForearm, outlinePaint);

    final rightArm = Path()
      ..moveTo(sx(70), sy(23))
      ..quadraticBezierTo(sx(82), sy(28), sx(85), sy(38))
      ..quadraticBezierTo(sx(87), sy(48), sx(86), sy(58))
      ..quadraticBezierTo(sx(84), sy(62), sx(80), sy(60))
      ..quadraticBezierTo(sx(78), sy(50), sx(76), sy(40))
      ..lineTo(sx(72), sy(28))
      ..close();
    canvas.drawPath(rightArm, bodyPaint);
    canvas.drawPath(rightArm, outlinePaint);

    final rightForearm = Path()
      ..moveTo(sx(86), sy(58))
      ..quadraticBezierTo(sx(88), sy(68), sx(87), sy(76))
      ..quadraticBezierTo(sx(86), sy(80), sx(83), sy(79))
      ..quadraticBezierTo(sx(81), sy(71), sx(80), sy(62))
      ..close();
    canvas.drawPath(rightForearm, bodyPaint);
    canvas.drawPath(rightForearm, outlinePaint);

    final leftLeg = Path()
      ..moveTo(sx(34), sy(68))
      ..quadraticBezierTo(sx(28), sy(72), sx(26), sy(90))
      ..quadraticBezierTo(sx(24), sy(108), sx(26), sy(118))
      ..quadraticBezierTo(sx(30), sy(122), sx(35), sy(120))
      ..quadraticBezierTo(sx(38), sy(108), sx(40), sy(90))
      ..lineTo(sx(42), sy(70))
      ..close();
    canvas.drawPath(leftLeg, bodyPaint);
    canvas.drawPath(leftLeg, outlinePaint);

    final leftShin = Path()
      ..moveTo(sx(26), sy(118))
      ..quadraticBezierTo(sx(24), sy(132), sx(25), sy(148))
      ..quadraticBezierTo(sx(26), sy(154), sx(30), sy(153))
      ..quadraticBezierTo(sx(33), sy(148), sx(34), sy(134))
      ..quadraticBezierTo(sx(35), sy(124), sx(35), sy(120))
      ..close();
    canvas.drawPath(leftShin, bodyPaint);
    canvas.drawPath(leftShin, outlinePaint);

    final rightLeg = Path()
      ..moveTo(sx(66), sy(68))
      ..quadraticBezierTo(sx(72), sy(72), sx(74), sy(90))
      ..quadraticBezierTo(sx(76), sy(108), sx(74), sy(118))
      ..quadraticBezierTo(sx(70), sy(122), sx(65), sy(120))
      ..quadraticBezierTo(sx(62), sy(108), sx(60), sy(90))
      ..lineTo(sx(58), sy(70))
      ..close();
    canvas.drawPath(rightLeg, bodyPaint);
    canvas.drawPath(rightLeg, outlinePaint);

    final rightShin = Path()
      ..moveTo(sx(74), sy(118))
      ..quadraticBezierTo(sx(76), sy(132), sx(75), sy(148))
      ..quadraticBezierTo(sx(74), sy(154), sx(70), sy(153))
      ..quadraticBezierTo(sx(67), sy(148), sx(66), sy(134))
      ..quadraticBezierTo(sx(65), sy(124), sx(65), sy(120))
      ..close();
    canvas.drawPath(rightShin, bodyPaint);
    canvas.drawPath(rightShin, outlinePaint);

    canvas.drawOval(Rect.fromCenter(center: s(27, 155), width: sx(12), height: sy(6)), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: s(73, 155), width: sx(12), height: sy(6)), bodyPaint);

    // ── Músculos traseros ──
    final musclePaint = Paint()..style = PaintingStyle.fill;

    // Trapecio
    musclePaint.color = getColor('trapecio');
    final trapPath = Path()
      ..moveTo(sx(41), sy(20))
      ..quadraticBezierTo(sx(50), sy(28), sx(59), sy(20))
      ..lineTo(sx(65), sy(30))
      ..quadraticBezierTo(sx(50), sy(36), sx(35), sy(30))
      ..close();
    canvas.drawPath(trapPath, musclePaint);

    // Deltoides
    musclePaint.color = getColor('deltoides');
    canvas.drawOval(Rect.fromCenter(center: s(27, 27), width: sx(12), height: sy(10)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(73, 27), width: sx(12), height: sy(10)), musclePaint);

    // Dorsales
    musclePaint.color = getColor('dorsales');
    final leftLat = Path()
      ..moveTo(sx(32), sy(35))
      ..quadraticBezierTo(sx(25), sy(45), sx(26), sy(58))
      ..quadraticBezierTo(sx(35), sy(62), sx(42), sy(58))
      ..lineTo(sx(44), sy(38))
      ..close();
    canvas.drawPath(leftLat, musclePaint);
    final rightLat = Path()
      ..moveTo(sx(68), sy(35))
      ..quadraticBezierTo(sx(75), sy(45), sx(74), sy(58))
      ..quadraticBezierTo(sx(65), sy(62), sx(58), sy(58))
      ..lineTo(sx(56), sy(38))
      ..close();
    canvas.drawPath(rightLat, musclePaint);

    // Tríceps
    musclePaint.color = getColor('triceps');
    _drawRotatedOval(canvas, s(17, 38), sx(8), sy(16), -0.17, musclePaint);
    _drawRotatedOval(canvas, s(83, 38), sx(8), sy(16), 0.17, musclePaint);

    // Core / lumbar
    musclePaint.color = getColor('core');
    canvas.drawOval(Rect.fromCenter(center: s(50, 58), width: sx(16), height: sy(12)), musclePaint);

    // Glúteos
    musclePaint.color = getColor('gluteos');
    canvas.drawOval(Rect.fromCenter(center: s(40, 72), width: sx(20), height: sy(18)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(60, 72), width: sx(20), height: sy(18)), musclePaint);

    // Isquiotibiales
    musclePaint.color = getColor('isquiotibiales');
    canvas.drawOval(Rect.fromCenter(center: s(34, 95), width: sx(14), height: sy(32)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(66, 95), width: sx(14), height: sy(32)), musclePaint);

    // Gemelos
    musclePaint.color = getColor('gemelos');
    canvas.drawOval(Rect.fromCenter(center: s(28, 133), width: sx(10), height: sy(20)), musclePaint);
    canvas.drawOval(Rect.fromCenter(center: s(72, 133), width: sx(10), height: sy(20)), musclePaint);
  }

  void _drawRotatedOval(Canvas canvas, Offset center, double width, double height, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: width, height: height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackPainter oldDelegate) => true;
}