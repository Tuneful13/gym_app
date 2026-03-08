import 'package:flutter/material.dart';
import 'models.dart';

class DetalleEjercicio extends StatefulWidget {
  final Ejercicio ejercicio;
  final VoidCallback onActualizado;

  const DetalleEjercicio({
    super.key, 
    required this.ejercicio, 
    required this.onActualizado
  });

  @override
  State<DetalleEjercicio> createState() => _DetalleEjercicioState();
}

class _DetalleEjercicioState extends State<DetalleEjercicio> {
  final _pesoCtrl = TextEditingController();
  final _repesCtrl = TextEditingController();

  void _guardar() {
    if (_pesoCtrl.text.isNotEmpty && _repesCtrl.text.isNotEmpty) {
      setState(() {
        widget.ejercicio.series.add(Serie(_pesoCtrl.text, _repesCtrl.text));
      });
      _pesoCtrl.clear();
      _repesCtrl.clear();
      widget.onActualizado(); 
    }
  }

  void _mostrarDialogoEdicion(int index) {
    final editarPesoCtrl = TextEditingController(text: widget.ejercicio.series[index].peso);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar peso (${widget.ejercicio.series[index].repes} reps)'),
          content: TextField(
            controller: editarPesoCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nuevo peso (kg)'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (editarPesoCtrl.text.isNotEmpty) {
                  setState(() {
                    widget.ejercicio.series[index].peso = editarPesoCtrl.text;
                  });
                  widget.onActualizado();
                  Navigator.pop(context);
                }
              }, 
              child: const Text('Actualizar')
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lógica de ordenamiento para PRs
    final seriesOrdenadas = List<Serie>.from(widget.ejercicio.series);
    seriesOrdenadas.sort((a, b) {
      double pesoA = double.tryParse(a.peso) ?? 0;
      double pesoB = double.tryParse(b.peso) ?? 0;
      return pesoB.compareTo(pesoA); 
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.ejercicio.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _pesoCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number),
            TextField(controller: _repesCtrl, decoration: const InputDecoration(labelText: 'Repes'), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _guardar, child: const Text('Añadir Serie')),
            
            const Divider(height: 30),
            
            // CORRECCIÓN: Quitamos el const de aquí porque el icono o el texto podrían dar conflicto
            if (seriesOrdenadas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swipe_left, size: 16, color: Colors.grey), // "swipe", no "swap"
                    const SizedBox(width: 5),
                    const Text('Desliza para eliminar | PR arriba', 
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: seriesOrdenadas.length,
                itemBuilder: (context, index) {
                  final s = seriesOrdenadas[index];
                  final int originalIndex = widget.ejercicio.series.indexOf(s);
                  bool esPR = index == 0 && (double.tryParse(s.peso) ?? 0) > 0;

                  return Dismissible(
                    key: ObjectKey(s),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(esPR ? "¡Atención: Es un PR!" : "Confirmar"),
                          content: Text("¿Eliminar serie de ${s.repes} x ${s.peso}kg?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("NO")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("SÍ")),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      setState(() => widget.ejercicio.series.removeAt(originalIndex));
                      widget.onActualizado();
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      // Aquí NO debe haber const porque esPR es dinámico
                      color: esPR ? Colors.amber.shade50 : null,
                      elevation: esPR ? 4 : 1,
                      child: ListTile(
                        leading: esPR 
                            ? const Icon(Icons.emoji_events, color: Colors.amber, size: 30) 
                            : const Icon(Icons.fitness_center, color: Colors.grey),
                        title: Text(
                          '${s.repes} x ${s.peso}kg',
                          style: TextStyle(
                            fontWeight: esPR ? FontWeight.bold : FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: esPR ? const Text("PESO MÁXIMO", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10)) : null,
                        trailing: const Icon(Icons.edit, size: 20),
                        onTap: () => _mostrarDialogoEdicion(originalIndex),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}