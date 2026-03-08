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
        double nuevoPeso = double.tryParse(_pesoCtrl.text) ?? 0;
        String repeticiones = _repesCtrl.text;

        // Buscamos si ya existe una serie con ese mismo número de repeticiones
        int indexExistente = widget.ejercicio.series.indexWhere((s) => s.repes == repeticiones);

        if (indexExistente != -1) {
          // Si existe, comparamos pesos
          double pesoAntiguo = double.tryParse(widget.ejercicio.series[indexExistente].peso) ?? 0;
          if (nuevoPeso > pesoAntiguo) {
            widget.ejercicio.series[indexExistente].peso = _pesoCtrl.text;
          }
        } else {
          // Si no existe ese rango de repeticiones, lo añadimos como nuevo récord
          widget.ejercicio.series.add(Serie(_pesoCtrl.text, repeticiones));
        }
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
  @override
Widget build(BuildContext context) {
  // 1. Ordenamos por repeticiones (de 1 a N)
  final seriesOrdenadasPorRepes = List<Serie>.from(widget.ejercicio.series);
  seriesOrdenadasPorRepes.sort((a, b) {
    int rA = int.tryParse(a.repes) ?? 0;
    int rB = int.tryParse(b.repes) ?? 0;
    return rA.compareTo(rB);
  });

  return Scaffold(
    appBar: AppBar(title: Text('Récords: ${widget.ejercicio.nombre}')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Sección de entrada
          TextField(controller: _pesoCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number),
          TextField(controller: _repesCtrl, decoration: const InputDecoration(labelText: 'Repeticiones'), keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _guardar, 
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
            child: const Text('Registrar Marca'),
          ),
          
          const Divider(height: 40),

          // --- RECUPERADO: AVISO DE DESLIZAR ---
          if (seriesOrdenadasPorRepes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Desliza para eliminar marca', 
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: seriesOrdenadasPorRepes.length,
              itemBuilder: (context, index) {
                final s = seriesOrdenadasPorRepes[index];
                final int originalIndex = widget.ejercicio.series.indexOf(s);
                
                // Cálculo del 1RM corregido
                double w = double.tryParse(s.peso) ?? 0;
                double r = double.tryParse(s.repes) ?? 0;
                double oneRM = (r <= 1) ? w : w * (1 + (r / 30));

                return Dismissible(
                  key: ObjectKey(s),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Eliminar Récord"),
                        content: Text("¿Borrar marca de ${s.peso}kg a ${s.repes} reps?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("BORRAR", style: TextStyle(color: Colors.red))),
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
                    child: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade900,
                        radius: 25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s.repes, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            const Text('REPS', style: TextStyle(color: Colors.white, fontSize: 8)),
                          ],
                        ),
                      ),
                      title: Text(
                        '${s.peso} kg',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        r <= 1 ? "Récord Absoluto" : "1RM Est: ${oneRM.toStringAsFixed(1)} kg",
                        style: TextStyle(
                          color: r <= 1 ? Colors.orange.shade800 : Colors.blue.shade700, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.grey),
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