import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models.dart';
import 'muscle_diagram.dart';

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
  late TabController _tabController;
  String? _repsFiltro;

  final List<Color> _lineColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesoCtrl.dispose();
    _repesCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_pesoCtrl.text.isNotEmpty && _repesCtrl.text.isNotEmpty) {
      setState(() {
        widget.ejercicio.series.add(
          Serie(_pesoCtrl.text, _repesCtrl.text, DateTime.now()),
        );
      });
      _pesoCtrl.clear();
      _repesCtrl.clear();
      widget.onActualizado();
    }
  }

  void _mostrarDialogoEdicion(String repes) {
    final record = widget.ejercicio.records.firstWhere((s) => s.repes == repes);
    final editarPesoCtrl = TextEditingController(text: record.peso);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar peso ($repes reps)'),
          content: TextField(
            controller: editarPesoCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nuevo peso (kg)'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editarPesoCtrl.text.isNotEmpty) {
                  setState(() {
                    widget.ejercicio.series.add(
                      Serie(editarPesoCtrl.text, repes, DateTime.now()),
                    );
                  });
                  widget.onActualizado();
                  Navigator.pop(context);
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarRecord(String repes) {
    setState(() {
      widget.ejercicio.series.removeWhere((s) => s.repes == repes);
    });
    widget.onActualizado();
  }

  // ─── VISTA DE RÉCORDS ───────────────────────────────────────────────────────

  Widget _buildRecordsTab() {
  final records = widget.ejercicio.records;
  final mejorSerie = widget.ejercicio.mejorSerie;
  final oneRMActual = widget.ejercicio.oneRMActual;

    // Ordenación: 1 rep primero, luego por 1RM estimado descendente
    double _calcOneRM(Serie s) {
      double w = double.tryParse(s.peso) ?? 0;
      double r = double.tryParse(s.repes) ?? 0;
      return r <= 1 ? w : w * (1 + r / 30);
    }

    final recordsOrdenados = List<Serie>.from(records)..sort((a, b) {
      bool aEs1 = (int.tryParse(a.repes) ?? 0) == 1;
      bool bEs1 = (int.tryParse(b.repes) ?? 0) == 1;
      if (aEs1 && !bEs1) return -1;
      if (!aEs1 && bEs1) return 1;
      return _calcOneRM(b).compareTo(_calcOneRM(a)); // descendente por 1RM
    });

    // Color del rep count que origina el 1RM
    const Color colorDestacado = Color(0xFF1565C0); // azul oscuro

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // ── Hero 1RM ──────────────────────────────────────────────────────
          if (records.isNotEmpty && mejorSerie != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: colorDestacado.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorDestacado.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    '${oneRMActual.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: colorDestacado,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '1RM ESTIMADO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Calculado desde  ',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorDestacado.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${mejorSerie.peso} kg × ${mejorSerie.repes} reps',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorDestacado,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ── Formulario ────────────────────────────────────────────────────
          TextField(
            controller: _pesoCtrl,
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _repesCtrl,
            decoration: const InputDecoration(labelText: 'Repeticiones'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _guardar,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Registrar Marca'),
          ),
          const Divider(height: 32),

          // ── Aviso deslizar ────────────────────────────────────────────────
          if (records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Desliza para eliminar marca',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // ── Lista de PRs ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: recordsOrdenados.length,
              itemBuilder: (context, index) {
                final s = recordsOrdenados[index];
                final bool esDestacada = mejorSerie != null && s.repes == mejorSerie.repes;
                double w = double.tryParse(s.peso) ?? 0;
                double r = double.tryParse(s.repes) ?? 0;
                double oneRM = r <= 1 ? w : w * (1 + r / 30);

                // Peso máximo para calcular la barra proporcional
                final double maxOneRM = oneRMActual > 0 ? oneRMActual : 1;

                return Dismissible(
                  key: ValueKey('${s.repes}_record'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Eliminar Récord"),
                        content: Text("¿Borrar todas las marcas de ${s.repes} reps?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("CANCELAR"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("BORRAR",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => _eliminarRecord(s.repes),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: esDestacada ? 3 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: esDestacada
                          ? BorderSide(color: colorDestacado.withOpacity(0.4), width: 1.5)
                          : BorderSide.none,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: esDestacada ? colorDestacado : Colors.blue.shade900,
                            radius: 25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(s.repes,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const Text('REPS',
                                    style: TextStyle(color: Colors.white, fontSize: 8)),
                              ],
                            ),
                          ),
                          title: Text(
                            '${s.peso} kg',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: esDestacada ? colorDestacado : null,
                            ),
                          ),
                          subtitle: esDestacada
                          ? Text(
                        'Origen de estimación',
                        style: TextStyle(
                          color: colorDestacado,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : (r <= 1
                        ? null  // 1 rep no necesita subtitle, el peso ya lo dice todo
                        : Text(
                            '1RM Est: ${oneRM.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          trailing: GestureDetector(
                            onTap: () => _mostrarDialogoEdicion(s.repes),
                            child: Icon(Icons.edit,
                                color: esDestacada ? colorDestacado : Colors.grey),
                          ),
                          onTap: () {
                            setState(() => _repsFiltro = s.repes);
                            _tabController.animateTo(1);
                          },
                        ),
                        // Barra proporcional
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: oneRM / maxOneRM,
                              minHeight: 4,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                esDestacada ? colorDestacado : Colors.blue.shade300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  // ─── VISTA DE GRÁFICO ───────────────────────────────────────────────────────

  Widget _buildGraficoTab() {
    final Map<String, List<Serie>> porReps = {};
    for (final s in widget.ejercicio.series) {
      porReps.putIfAbsent(s.repes, () => []).add(s);
    }

    if (porReps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Registra marcas para\nver tu evolución',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
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

    final todasLasFechas = widget.ejercicio.series.map((s) => s.fecha).toList()
      ..sort();
    final fechaBase = todasLasFechas.first;

    final lineas = <LineChartBarData>[];
    for (int i = 0; i < repCounts.length; i++) {
      final reps = repCounts[i];
      final seriesDeEstasReps = List<Serie>.from(porReps[reps]!)
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

      final puntos = seriesDeEstasReps.map((s) {
        final diasDesdeBase = s.fecha.difference(fechaBase).inDays.toDouble();
        final peso = double.tryParse(s.peso) ?? 0;
        return FlSpot(diasDesdeBase, peso);
      }).toList();

      // Color fijo basado en el rep count original (no en el índice filtrado)
      final allRepCounts = porReps.keys.toList()
        ..sort((a, b) =>
            (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
      final colorIndex = allRepCounts.indexOf(reps);

      lineas.add(
        LineChartBarData(
          spots: puntos,
          isCurved: true,
          curveSmoothness: 0.3,
          color: _lineColors[colorIndex % _lineColors.length],
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: bar.color ?? Colors.blue,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _lineColors[colorIndex % _lineColors.length].withOpacity(0.08),
          ),
        ),
      );
    }

    final todosLosPesos = widget.ejercicio.series
        .where((s) => _repsFiltro == null || s.repes == _repsFiltro)
        .map((s) => double.tryParse(s.peso) ?? 0)
        .toList();
    final maxPeso = todosLosPesos.reduce((a, b) => a > b ? a : b);
    final minPeso = todosLosPesos.reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chip de filtro activo
          if (_repsFiltro != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Chip(
                    label: Text('$_repsFiltro reps'),
                    avatar: const Icon(Icons.filter_list, size: 16),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _repsFiltro = null),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mostrando solo estas reps',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          // Leyenda
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: List.generate(repCounts.length, (i) {
              final allRepCounts = porReps.keys.toList()
                ..sort((a, b) =>
                    (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
              final colorIndex = allRepCounts.indexOf(repCounts[i]);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _lineColors[colorIndex % _lineColors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${repCounts[i]} reps',
                      style: const TextStyle(fontSize: 12)),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),
          // Gráfico
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
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final fecha =
                            fechaBase.add(Duration(days: value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${fecha.day}/${fecha.month}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
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
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
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
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final allRepCounts = porReps.keys.toList()
                          ..sort((a, b) => (int.tryParse(a) ?? 0)
                              .compareTo(int.tryParse(b) ?? 0));
                        final reps = repCounts[spot.barIndex];
                        final colorIndex = allRepCounts.indexOf(reps);
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} kg\n$reps reps',
                          TextStyle(
                            color: _lineColors[colorIndex % _lineColors.length],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
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
              // Leyenda + botón editar
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

              // Diagrama
              Expanded(
                child: MuscleDiagram(
                  principales: widget.ejercicio.musculosPrincipales,
                  secundarios: widget.ejercicio.musculosSecundarios,
                ),
              ),

              const SizedBox(height: 16),

              // Chips resumen
              if (widget.ejercicio.musculosPrincipales.isNotEmpty) ...[
                Text('Principal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: widget.ejercicio.musculosPrincipales.map((id) {
                    final label = todosLosMusculosInfo.firstWhere((m) => m['id'] == id)['label'];
                    return Chip(
                      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                Text('Secundario', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: widget.ejercicio.musculosSecundarios.map((id) {
                    final label = todosLosMusculosInfo.firstWhere((m) => m['id'] == id)['label'];
                    return Chip(
                      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  void _mostrarEditorMusculos(StateSetter setLocalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            String _getEstado(String id) {
              if (widget.ejercicio.musculosPrincipales.contains(id)) return 'principal';
              if (widget.ejercicio.musculosSecundarios.contains(id)) return 'secundario';
              return 'none';
            }

            void _toggle(String id, String tipo) {
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
                    // Handle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text('Editar músculos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Toca para activar/desactivar',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    const Divider(height: 24),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: todosLosMusculosInfo.map((m) {
                          final id = m['id'] as String;
                          final label = m['label'] as String;
                          final estado = _getEstado(id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(label,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                ),
                                // Botón Principal
                                GestureDetector(
                                  onTap: () => _toggle(id, 'principal'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: estado == 'principal' ? Colors.red : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('Principal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: estado == 'principal' ? Colors.white : Colors.grey.shade500,
                                      )),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botón Secundario
                                GestureDetector(
                                  onTap: () => _toggle(id, 'secundario'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: estado == 'secundario' ? Colors.orange : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('Secundario',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: estado == 'secundario' ? Colors.white : Colors.grey.shade500,
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
      appBar: AppBar(
        title: Text(widget.ejercicio.nombre),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events), text: 'Récords'),
            Tab(icon: Icon(Icons.show_chart), text: 'Evolución'),
            Tab(icon: Icon(Icons.accessibility_new), text: 'Músculos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsTab(),
          _buildGraficoTab(),
          _buildMusculosTab(),
        ],
      ),
    );
  }
}