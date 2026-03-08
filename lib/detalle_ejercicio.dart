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

  // --- NUEVA FUNCIÓN PARA EDITAR EL PESO ---
  void _mostrarDialogoEdicion(int index) {
    // Creamos un controlador pre-rellenado con el peso actual
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
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: () {
                if (editarPesoCtrl.text.isNotEmpty) {
                  setState(() {
                    // Actualizamos el peso en la lista
                    widget.ejercicio.series[index].peso = editarPesoCtrl.text;
                  });
                  widget.onActualizado(); // Avisamos a la pantalla principal
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
            const Divider(),
            const Text('Toca una serie para editar el peso', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.ejercicio.series.length,
                itemBuilder: (context, index) {
                  final s = widget.ejercicio.series[index];
                  return Card(
                    child: ListTile(
                      title: Text('Serie ${index + 1}: ${s.repes} x ${s.peso}kg'),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () => _mostrarDialogoEdicion(index), // Llamamos a la edición
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