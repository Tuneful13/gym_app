import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models.dart';
import 'muscle_diagram.dart';

// ─── Paleta ────────────────────────────────────────────────────────────────────
const _kAccent = Color(0xFF1565C0);       // azul primario
const _kAccentLight = Color(0xFFE3F2FD);  // fondo azul suave
const _kSurface = Colors.white;
const _kBg = Color(0xFFF5F7FA);

class DetalleEjercicio extends StatefulWidget {
  final Ejercicio ejercicio;
  final VoidCallback onActualizado;

  const DetalleEjercicio({
    super.key,
    required this.ejercicio,
    required this.onActualizado,
  });

  @override
  State<DetalleEjercicio> createState() => _DetalleEjercicioState();
}

class _DetalleEjercicioState extends State<DetalleEjercicio>
    with SingleTickerProviderStateMixin {
  final _pesoCtrl = TextEditingController();
  final _repesCtrl = TextEditingController();
  late final TextEditingController _notaCtrl;
  late TabController _tabController;
  String? _repsFiltro;

  bool _mostrarTodoHistorial = false;

  final List<Color> _lineColors = [
    _kAccent, Colors.red.shade600, Colors.green.shade600,
    Colors.orange.shade600, Colors.purple.shade600, Colors.teal.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notaCtrl = TextEditingController(text: widget.ejercicio.nota ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesoCtrl.dispose();
    _repesCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Sesion? _sesionHoy() {
    final hoy = DateTime.now();
    try {
      return widget.ejercicio.sesiones.firstWhere((s) => _mismoDia(s.fecha, hoy));
    } catch (_) {
      return null;
    }
  }

  void _repetirSesion(Sesion sesion) {
    final ahora = DateTime.now();
    setState(() {
      Sesion? sesionHoy = _sesionHoy();
      if (sesionHoy == null) {
        sesionHoy = Sesion(ahora, []);
        widget.ejercicio.sesiones.insert(0, sesionHoy);
      }
      for (final s in sesion.sets) {
        sesionHoy.sets.add(Serie(s.peso, s.repes, ahora));
      }
    });
    widget.onActualizado();
  }

  void _agregarSet() {
    if (_pesoCtrl.text.isNotEmpty && _repesCtrl.text.isNotEmpty) {
      final ahora = DateTime.now();
      setState(() {
        Sesion? sesion = _sesionHoy();
        if (sesion == null) {
          sesion = Sesion(ahora, []);
          widget.ejercicio.sesiones.insert(0, sesion);
        }
        sesion.sets.add(Serie(_pesoCtrl.text, _repesCtrl.text, ahora));
      });
      _pesoCtrl.clear();
      _repesCtrl.clear();
      widget.onActualizado();
    }
  }

  void _eliminarSet(Sesion sesion, int index) {
    setState(() {
      sesion.sets.removeAt(index);
      if (sesion.sets.isEmpty) widget.ejercicio.sesiones.remove(sesion);
    });
    widget.onActualizado();
  }

  void _editarSet(List<Serie> sets, int index, String peso, String repes) {
    setState(() {
      final viejo = sets[index];
      sets[index] = Serie(peso, repes, viejo.fecha);
    });
    widget.onActualizado();
  }

  void _eliminarSesion(Sesion sesion) {
    setState(() => widget.ejercicio.sesiones.remove(sesion));
    widget.onActualizado();
  }

  // ─── NOTAS ──────────────────────────────────────────────────────────────────

  Widget _buildNotasSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.sticky_note_2_outlined,
                size: 16, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _notaCtrl,
              decoration: InputDecoration(
                hintText: 'Notas del ejercicio...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: null,
              onChanged: (val) {
                widget.ejercicio.nota = val.trim().isEmpty ? null : val;
                widget.onActualizado();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── SETS VERTICAL ──────────────────────────────────────────────────────────

  Widget _buildSetsVertical({required List<Serie> sets}) {
    if (sets.isEmpty) return const SizedBox.shrink();
    return Column(
      children: sets.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${s.peso} kg  ×  ${s.repes} reps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── VISTA DE ENTRENAMIENTO ─────────────────────────────────────────────────

  Widget _buildEntrenamientoTab() {
    final sesionHoy = _sesionHoy();
    final haySetHoy = sesionHoy != null && sesionHoy.sets.isNotEmpty;

    final sesionesAntes = widget.ejercicio.sesiones
        .where((s) => !_mismoDia(s.fecha, DateTime.now()))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    final ultimaSesion = sesionesAntes.isNotEmpty ? sesionesAntes.first : null;

    return Container(
      color: _kBg,
      child: ListView(
        children: [
          // ── Notas ─────────────────────────────────────────────────────────
          _buildNotasSection(),

          // ── Card fantasma: última sesión ───────────────────────────────────
          if (ultimaSesion != null && !haySetHoy)
            _buildGhostUltimaSesion(ultimaSesion),

          const SizedBox(height: 12),

          // ── Sesión de hoy ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header "HOY"
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  decoration: BoxDecoration(
                    color: _kAccentLight,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _labelFechaHoy(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sets de hoy
                      if (!haySetHoy)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Añade el primer set de hoy',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13),
                          ),
                        )
                      else ...[
                        ...sesionHoy.sets.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          return _SetRowEditable(
                            key: ValueKey('hoy-$i'),
                            index: i,
                            peso: s.peso,
                            repes: s.repes,
                            isToday: true,
                            onDelete: () => _eliminarSet(sesionHoy, i),
                            onChanged: (p, r) =>
                                _editarSet(sesionHoy.sets, i, p, r),
                          );
                        }),
                        const SizedBox(height: 14),
                      ],

                      // Formulario
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _pesoCtrl,
                              label: 'Peso (kg)',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InputField(
                              controller: _repesCtrl,
                              label: 'Reps',
                              onSubmitted: (_) => _agregarSet(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _agregarSet,
                              style: FilledButton.styleFrom(
                                backgroundColor: _kAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18),
                              ),
                              child: const Icon(Icons.add, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Récords personales ────────────────────────────────────────────
          if (widget.ejercicio.sesiones.isNotEmpty)
            _buildPRsSection(widget.ejercicio.sesiones),

          // ── Historial ──────────────────────────────────────────────────────
          if (sesionesAntes.isNotEmpty) ...[
            _sectionLabel('HISTORIAL',
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8)),
            ...(_mostrarTodoHistorial
                    ? sesionesAntes
                    : sesionesAntes.take(3).toList())
                .map((sesion) => _SesionCard(
                      sesion: sesion,
                      onEliminar: () => _confirmarEliminarSesion(sesion),
                      onEditarSet: (i, p, r) =>
                          _editarSet(sesion.sets, i, p, r),
                      onEliminarSet: (i) => _eliminarSet(sesion, i),
                    )),
            if (sesionesAntes.length > 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _mostrarTodoHistorial = !_mostrarTodoHistorial),
                    icon: Icon(
                      _mostrarTodoHistorial
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                    ),
                    label: Text(
                      _mostrarTodoHistorial
                          ? 'Mostrar menos'
                          : 'Ver todas las sesiones (${sesionesAntes.length})',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Center(
                child: Text(
                  'Las sesiones anteriores aparecerán aquí',
                  style:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _labelFechaHoy() {
    final hoy = DateTime.now();
    const dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dias[hoy.weekday - 1]} ${hoy.day} ${meses[hoy.month - 1]}';
  }

  void _confirmarEliminarSesion(Sesion sesion) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sesión'),
        content: const Text('¿Borrar todos los sets de esta sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              _eliminarSesion(sesion);
              Navigator.pop(ctx);
            },
            child:
                const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGhostUltimaSesion(Sesion sesion) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade200, width: 1.5),
          color: _kSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history,
                            size: 13, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'ÚLTIMA SESIÓN · ${_SesionCard.formatFechaEstatica(sesion.fecha).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSetsVertical(sets: sesion.sets),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _repetirSesion(sesion),
                  icon: const Icon(Icons.replay, size: 17),
                  label: const Text('Usar como sesión de hoy'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RÉCORDS PERSONALES ─────────────────────────────────────────────────────

  Map<String, double> _calcularPRs(List<Sesion> sesiones) {
    final Map<String, double> prs = {};
    for (final sesion in sesiones) {
      for (final s in sesion.sets) {
        final peso = double.tryParse(s.peso) ?? 0;
        if (!prs.containsKey(s.repes) || peso > prs[s.repes]!) {
          prs[s.repes] = peso;
        }
      }
    }

    // Eliminar dominados: si con más reps ya levantas el mismo peso o más,
    // el de menos reps al mismo peso no aporta nada.
    final sortedDesc = prs.keys.toList()
      ..sort((a, b) =>
          (int.tryParse(b) ?? 0).compareTo(int.tryParse(a) ?? 0));
    double maxVisto = 0;
    final dominados = <String>{};
    for (final reps in sortedDesc) {
      if (prs[reps]! <= maxVisto) {
        dominados.add(reps);
      } else {
        maxVisto = prs[reps]!;
      }
    }
    dominados.forEach(prs.remove);

    return prs;
  }

  Widget _buildPRsSection(List<Sesion> sesiones) {
    final prs = _calcularPRs(sesiones);
    if (prs.isEmpty) return const SizedBox.shrink();

    final sortedReps = prs.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('RÉCORDS PERSONALES',
              padding: const EdgeInsets.only(bottom: 10)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sortedReps.map((reps) {
                final peso = prs[reps]!;
                final esUnoRM = reps == '1';
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: esUnoRM ? _kAccent : _kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: esUnoRM
                            ? _kAccent
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (esUnoRM)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(Icons.emoji_events,
                                    size: 13,
                                    color: Colors.yellow.shade300),
                              ),
                            Text(
                              esUnoRM ? 'PR' : '$reps reps',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: esUnoRM
                                    ? Colors.white70
                                    : Colors.grey.shade500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          peso == peso.truncateToDouble()
                              ? '${peso.toInt()} kg'
                              : '$peso kg',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: esUnoRM ? Colors.white : Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── VISTA DE GRÁFICO ───────────────────────────────────────────────────────

  Widget _buildGraficoTab() {
    final Map<String, List<MapEntry<DateTime, double>>> porReps = {};
    for (final sesion in widget.ejercicio.sesiones) {
      // Máximo peso por rango de reps en esta sesión
      final Map<String, double> maxEnSesion = {};
      for (final s in sesion.sets) {
        final peso = double.tryParse(s.peso) ?? 0;
        if (!maxEnSesion.containsKey(s.repes) || peso > maxEnSesion[s.repes]!) {
          maxEnSesion[s.repes] = peso;
        }
      }
      // Filtrar dominados dentro de la sesión:
      // (reps=N, weight=W) es dominado si existe M>N con weight>=W en esta sesión
      final sortedDesc = maxEnSesion.keys.toList()
        ..sort((a, b) => (int.tryParse(b) ?? 0).compareTo(int.tryParse(a) ?? 0));
      double maxVisto = 0;
      final dominados = <String>{};
      for (final r in sortedDesc) {
        if (maxEnSesion[r]! <= maxVisto) {
          dominados.add(r);
        } else {
          maxVisto = maxEnSesion[r]!;
        }
      }
      for (final e in maxEnSesion.entries) {
        if (!dominados.contains(e.key)) {
          porReps.putIfAbsent(e.key, () => []).add(MapEntry(sesion.fecha, e.value));
        }
      }
    }

    if (porReps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Registra sesiones para\nver tu evolución',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      );
    }

    final repCounts = (porReps.keys.toList()
          ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0)))
        .where((r) => _repsFiltro == null || r == _repsFiltro)
        .toList();

    final todasLasFechas = widget.ejercicio.sesiones.map((s) => s.fecha).toList()..sort();
    final fechaBase = todasLasFechas.first;

    final allRepCounts = porReps.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    // ── Detectar días con PR por rango ──────────────────────────────────
    final Map<String, Set<int>> prDays = {};
    {
      final sorted = widget.ejercicio.sesiones.toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
      final Map<String, double> maxAcum = {};
      for (final sesion in sorted) {
        final Map<String, double> maxHoy = {};
        for (final s in sesion.sets) {
          final w = double.tryParse(s.peso) ?? 0;
          if (!maxHoy.containsKey(s.repes) || w > maxHoy[s.repes]!) {
            maxHoy[s.repes] = w;
          }
        }
        for (final e in maxHoy.entries) {
          if (e.value > (maxAcum[e.key] ?? 0)) {
            maxAcum[e.key] = e.value;
            prDays.putIfAbsent(e.key, () => {})
                .add(sesion.fecha.difference(fechaBase).inDays);
          }
        }
      }
    }

    // ── e1RM estimado (Epley) por sesión ────────────────────────────────
    final List<FlSpot> e1RMSpots = [];
    for (final sesion in widget.ejercicio.sesiones) {
      double best = 0;
      for (final s in sesion.sets) {
        final w = double.tryParse(s.peso) ?? 0;
        final r = int.tryParse(s.repes) ?? 1;
        final e = r == 1 ? w : w * (1 + r / 30.0);
        if (e > best) best = e;
      }
      if (best > 0) {
        e1RMSpots.add(FlSpot(
          sesion.fecha.difference(fechaBase).inDays.toDouble(),
          double.parse(best.toStringAsFixed(1)),
        ));
      }
    }
    e1RMSpots.sort((a, b) => a.x.compareTo(b.x));
    final mostrarE1RM = e1RMSpots.length >= 2 && _repsFiltro == null;

    // ── Construir líneas ────────────────────────────────────────────────
    final lineas = <LineChartBarData>[];
    for (final reps in repCounts) {
      final puntos = (porReps[reps]!..sort((a, b) => a.key.compareTo(b.key)))
          .map((e) => FlSpot(e.key.difference(fechaBase).inDays.toDouble(), e.value))
          .toList();
      final colorIndex = allRepCounts.indexOf(reps);
      final color = _lineColors[colorIndex % _lineColors.length];
      lineas.add(LineChartBarData(
        spots: puntos,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) {
            final isPR = prDays[reps]?.contains(spot.x.toInt()) ?? false;
            if (isPR) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: bar.color ?? _kAccent,
              );
            }
            return FlDotCirclePainter(
              radius: 3.5,
              color: bar.color ?? _kAccent,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.07)),
      ));
    }
    if (mostrarE1RM) {
      lineas.add(LineChartBarData(
        spots: e1RMSpots,
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.amber.shade700,
        barWidth: 2,
        dashArray: [6, 4],
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    final todosPesos = widget.ejercicio.sesiones
        .expand((s) => s.sets)
        .where((s) => _repsFiltro == null || s.repes == _repsFiltro)
        .map((s) => double.tryParse(s.peso) ?? 0)
        .where((v) => v > 0)
        .toList();
    final maxPeso = [
      todosPesos.reduce((a, b) => a > b ? a : b),
      if (mostrarE1RM && e1RMSpots.isNotEmpty)
        e1RMSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b),
    ].reduce((a, b) => a > b ? a : b);
    final minPeso = todosPesos.reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_repsFiltro != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Chip(
                label: Text('$_repsFiltro reps'),
                avatar: const Icon(Icons.filter_list, size: 16),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _repsFiltro = null),
                backgroundColor: _kAccentLight,
              ),
            ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ...repCounts.map((reps) {
                final colorIndex = allRepCounts.indexOf(reps);
                final color = _lineColors[colorIndex % _lineColors.length];
                return GestureDetector(
                  onTap: () => setState(
                      () => _repsFiltro = _repsFiltro == reps ? null : reps),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16, height: 4,
                        decoration: BoxDecoration(
                            color: color, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 4),
                      Text('$reps reps', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }),
              if (mostrarE1RM)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16, height: 3,
                      decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 4),
                    Text('e1RM',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700)),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.grey.shade600, width: 2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Récord', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(40),
                minScale: 1.0,
                maxScale: 6.0,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: LineChart(
                    LineChartData(
                lineBarsData: lineas,
                minY: (minPeso - 5).clamp(0, double.infinity),
                maxY: maxPeso + 10,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('kg',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) {
                        final f = fechaBase.add(Duration(days: v.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${f.day}/${f.month}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      final isE1RM = mostrarE1RM && spot.barIndex == lineas.length - 1;
                      if (isE1RM) {
                        return LineTooltipItem(
                          'e1RM: ${spot.y.toStringAsFixed(1)} kg',
                          TextStyle(
                            color: Colors.amber.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }
                      final reps = repCounts[spot.barIndex];
                      final colorIndex = allRepCounts.indexOf(reps);
                      final isPR = prDays[reps]?.contains(spot.x.toInt()) ?? false;
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} kg · $reps reps'
                        '${isPR ? '\n🏆 Récord' : ''}',
                        TextStyle(
                          color: _lineColors[colorIndex % _lineColors.length],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── VISTA DE MÚSCULOS ──────────────────────────────────────────────────────

  Widget _buildMusculosTab() {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _legendChip(kColorMusculoPrincipal, 'Principal'),
                      const SizedBox(width: 12),
                      _legendChip(kColorMusculoSecundario, 'Secundario'),
                    ],
                  ),
                  FilledButton.tonal(
                    onPressed: () => _mostrarEditorMusculos(setLocalState),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 6),
                        Text('Editar'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: MuscleDiagram(
                  principales: widget.ejercicio.musculosPrincipales,
                  secundarios: widget.ejercicio.musculosSecundarios,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.ejercicio.musculosPrincipales.isNotEmpty) ...[
                _sectionLabel('Principal'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: widget.ejercicio.musculosPrincipales.map((id) {
                    final label = todosLosMusculosInfo
                        .firstWhere((m) => m['id'] == id)['label'];
                    return Chip(
                      label: Text(label,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.red.shade50,
                      side: BorderSide(color: Colors.red.shade200),
                      labelStyle: TextStyle(color: Colors.red.shade700),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
              if (widget.ejercicio.musculosSecundarios.isNotEmpty) ...[
                _sectionLabel('Secundario'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: widget.ejercicio.musculosSecundarios.map((id) {
                    final label = todosLosMusculosInfo
                        .firstWhere((m) => m['id'] == id)['label'];
                    return Chip(
                      label: Text(label,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.orange.shade50,
                      side: BorderSide(color: Colors.orange.shade200),
                      labelStyle: TextStyle(color: Colors.orange.shade700),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _legendChip(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  void _mostrarEditorMusculos(StateSetter setLocalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            String getEstado(String id) {
              if (widget.ejercicio.musculosPrincipales.contains(id)) return 'principal';
              if (widget.ejercicio.musculosSecundarios.contains(id)) return 'secundario';
              return 'none';
            }

            void toggle(String id, String tipo) {
              setSheetState(() {
                setLocalState(() {
                  setState(() {
                    if (tipo == 'principal') {
                      if (widget.ejercicio.musculosPrincipales.contains(id)) {
                        widget.ejercicio.musculosPrincipales.remove(id);
                      } else {
                        widget.ejercicio.musculosPrincipales.add(id);
                        widget.ejercicio.musculosSecundarios.remove(id);
                      }
                    } else {
                      if (widget.ejercicio.musculosSecundarios.contains(id)) {
                        widget.ejercicio.musculosSecundarios.remove(id);
                      } else {
                        widget.ejercicio.musculosSecundarios.add(id);
                        widget.ejercicio.musculosPrincipales.remove(id);
                      }
                    }
                  });
                });
              });
              widget.onActualizado();
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const Text('Editar músculos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Toca para activar/desactivar',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const Divider(height: 24),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: todosLosMusculosInfo.map((m) {
                          final id = m['id'] as String;
                          final label = m['label'] as String;
                          final estado = getEstado(id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(label,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                GestureDetector(
                                  onTap: () => toggle(id, 'principal'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: estado == 'principal'
                                          ? Colors.red
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('Principal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: estado == 'principal'
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => toggle(id, 'secundario'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: estado == 'secundario'
                                          ? Colors.orange
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('Secundario',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: estado == 'secundario'
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.ejercicio.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: _kSurface,
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: _kAccent,
              indicatorWeight: 3,
              labelColor: _kAccent,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.fitness_center, size: 18),
                    text: 'Entreno'),
                Tab(icon: Icon(Icons.show_chart, size: 18),
                    text: 'Evolución'),
                Tab(icon: Icon(Icons.accessibility_new, size: 18),
                    text: 'Músculos'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEntrenamientoTab(),
          _buildGraficoTab(),
          _buildMusculosTab(),
        ],
      ),
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────────────────────

Widget _sectionLabel(String text,
    {EdgeInsets padding = const EdgeInsets.only(bottom: 2)}) {
  return Padding(
    padding: padding,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.4,
      ),
    ),
  );
}

// ─── INPUT FIELD ────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String)? onSubmitted;

  const _InputField({
    required this.controller,
    required this.label,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      onSubmitted: onSubmitted,
    );
  }
}

// ─── SESION CARD ─────────────────────────────────────────────────────────────

class _SesionCard extends StatefulWidget {
  final Sesion sesion;
  final VoidCallback onEliminar;
  final void Function(int, String, String)? onEditarSet;
  final void Function(int)? onEliminarSet;

  const _SesionCard({
    required this.sesion,
    required this.onEliminar,
    this.onEditarSet,
    this.onEliminarSet,
  });

  static String formatFechaEstatica(DateTime fecha) {
    const dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dias[fecha.weekday - 1]} ${fecha.day} ${meses[fecha.month - 1]}';
  }

  @override
  State<_SesionCard> createState() => _SesionCardState();
}

class _SesionCardState extends State<_SesionCard> {
  bool _editando = false;

  @override
  Widget build(BuildContext context) {
    final sesion = widget.sesion;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _SesionCard.formatFechaEstatica(sesion.fecha),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Row(
                  children: [
                    if (widget.onEditarSet != null)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _editando = !_editando),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _editando
                                ? _kAccent
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _editando ? 'Listo' : 'Editar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _editando
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sesion.sets.length} sets',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onEliminar,
                      child: Icon(Icons.delete_outline,
                          size: 17, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...sesion.sets.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              if (_editando && widget.onEditarSet != null) {
                return _SetRowEditable(
                  key: ValueKey('hist-${sesion.fecha.millisecondsSinceEpoch}-$i'),
                  index: i,
                  peso: s.peso,
                  repes: s.repes,
                  isToday: false,
                  onDelete: widget.onEliminarSet != null
                      ? () => widget.onEliminarSet!(i)
                      : null,
                  onChanged: (p, r) => widget.onEditarSet!(i, p, r),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${s.peso} kg  ×  ${s.repes} reps',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── SET ROW EDITABLE ────────────────────────────────────────────────────────

class _SetRowEditable extends StatefulWidget {
  final int index;
  final String peso;
  final String repes;
  final bool isToday;
  final VoidCallback? onDelete;
  final void Function(String peso, String repes) onChanged;

  const _SetRowEditable({
    super.key,
    required this.index,
    required this.peso,
    required this.repes,
    this.isToday = false,
    this.onDelete,
    required this.onChanged,
  });

  @override
  State<_SetRowEditable> createState() => _SetRowEditableState();
}

class _SetRowEditableState extends State<_SetRowEditable> {
  late final TextEditingController _pesoCtrl;
  late final TextEditingController _repesCtrl;

  @override
  void initState() {
    super.initState();
    _pesoCtrl = TextEditingController(text: widget.peso);
    _repesCtrl = TextEditingController(text: widget.repes);
  }

  @override
  void didUpdateWidget(_SetRowEditable old) {
    super.didUpdateWidget(old);
    if (old.peso != widget.peso && _pesoCtrl.text != widget.peso) {
      _pesoCtrl.text = widget.peso;
    }
    if (old.repes != widget.repes && _repesCtrl.text != widget.repes) {
      _repesCtrl.text = widget.repes;
    }
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _repesCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final p = _pesoCtrl.text.trim();
    final r = _repesCtrl.text.trim();
    if (p.isNotEmpty && r.isNotEmpty) widget.onChanged(p, r);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.isToday ? _kAccent : Colors.grey.shade500,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.index + 1}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          _miniInput(_pesoCtrl, 'kg'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('×',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ),
          _miniInput(_repesCtrl, 'reps'),
          const Spacer(),
          if (widget.onDelete != null)
            GestureDetector(
              onTap: widget.onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close,
                    size: 16, color: Colors.grey.shade400),
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniInput(TextEditingController ctrl, String hint) {
    return SizedBox(
      width: 72,
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        onEditingComplete: _commit,
        onTapOutside: (_) => _commit(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(fontSize: 12, color: Colors.grey.shade400),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          filled: true,
          fillColor: widget.isToday ? _kAccentLight : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.isToday ? _kAccent : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
