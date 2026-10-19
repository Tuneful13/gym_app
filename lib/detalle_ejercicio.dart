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

  Widget _buildSetsVertical({
    required List<Serie> sets,
    void Function(int)? onDelete,
    bool isToday = false,
  }) {
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
                  color: isToday ? _kAccent : Colors.grey.shade700,
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
              Expanded(
                child: Text(
                  '${s.peso} kg  ×  ${s.repes} reps',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: () => onDelete(i),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        size: 16, color: Colors.grey.shade400),
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
                        _buildSetsVertical(
                          sets: sesionHoy.sets,
                          onDelete: (i) => _eliminarSet(sesionHoy, i),
                          isToday: true,
                        ),
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

          // ── Historial ──────────────────────────────────────────────────────
          if (sesionesAntes.isNotEmpty) ...[
            _sectionLabel('HISTORIAL',
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8)),
            ...sesionesAntes.map((sesion) => _SesionCard(
                  sesion: sesion,
                  onEliminar: () => _confirmarEliminarSesion(sesion),
                )),
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
                    _buildSetsVertical(sets: sesion.sets, isToday: false),
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

  // ─── VISTA DE GRÁFICO ───────────────────────────────────────────────────────

  Widget _buildGraficoTab() {
    final Map<String, List<MapEntry<DateTime, double>>> porReps = {};
    for (final sesion in widget.ejercicio.sesiones) {
      final Map<String, double> maxPorReps = {};
      for (final s in sesion.sets) {
        final peso = double.tryParse(s.peso) ?? 0;
        if (!maxPorReps.containsKey(s.repes) || peso > maxPorReps[s.repes]!) {
          maxPorReps[s.repes] = peso;
        }
      }
      for (final e in maxPorReps.entries) {
        porReps.putIfAbsent(e.key, () => []).add(MapEntry(sesion.fecha, e.value));
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
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  height: 1.5),
            ),
          ],
        ),
      );
    }

    final repCounts = (porReps.keys.toList()
          ..sort((a, b) =>
              (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0)))
        .where((r) => _repsFiltro == null || r == _repsFiltro)
        .toList();

    final todasLasFechas =
        widget.ejercicio.sesiones.map((s) => s.fecha).toList()..sort();
    final fechaBase = todasLasFechas.first;

    final allRepCounts = porReps.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    final lineas = <LineChartBarData>[];
    for (final reps in repCounts) {
      final puntos = (porReps[reps]!..sort((a, b) => a.key.compareTo(b.key)))
          .map((e) => FlSpot(
              e.key.difference(fechaBase).inDays.toDouble(), e.value))
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
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            radius: 4,
            color: bar.color ?? _kAccent,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.07),
        ),
      ));
    }

    final todosPesos = widget.ejercicio.sesiones
        .expand((s) => s.sets)
        .where((s) => _repsFiltro == null || s.repes == _repsFiltro)
        .map((s) => double.tryParse(s.peso) ?? 0)
        .toList();
    final maxPeso = todosPesos.reduce((a, b) => a > b ? a : b);
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
            runSpacing: 6,
            children: repCounts.map((reps) {
              final colorIndex = allRepCounts.indexOf(reps);
              final color = _lineColors[colorIndex % _lineColors.length];
              return GestureDetector(
                onTap: () => setState(
                    () => _repsFiltro = _repsFiltro == reps ? null : reps),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 4),
                    Text('$reps reps',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Expanded(
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
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
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
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.grey.shade200, strokeWidth: 1),
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
                      final reps = repCounts[spot.barIndex];
                      final colorIndex = allRepCounts.indexOf(reps);
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} kg\n$reps reps',
                        TextStyle(
                          color: _lineColors[
                              colorIndex % _lineColors.length],
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
                      _legendChip(Colors.red, 'Principal'),
                      const SizedBox(width: 12),
                      _legendChip(Colors.orange, 'Secundario'),
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

class _SesionCard extends StatelessWidget {
  final Sesion sesion;
  final VoidCallback onEliminar;

  const _SesionCard({required this.sesion, required this.onEliminar});

  static String formatFechaEstatica(DateTime fecha) {
    const dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dias[fecha.weekday - 1]} ${fecha.day} ${meses[fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
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
                  formatFechaEstatica(sesion.fecha),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Row(
                  children: [
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
                            fontSize: 11, color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onEliminar,
                      child: Icon(Icons.delete_outline,
                          size: 17, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Sets en vertical
            ...sesion.sets.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
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
