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
            
            // 1. AVISO DE DESLIZAR (Mejora visual)
            if (widget.ejercicio.series.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe_left, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text('Desliza a la izquierda para eliminar', 
                         style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: widget.ejercicio.series.length,
                itemBuilder: (context, index) {
                  final s = widget.ejercicio.series[index];
                  
                  return Dismissible(
                    key: UniqueKey(), // Usamos UniqueKey para evitar errores al eliminar
                    direction: DismissDirection.endToStart,
                    
                    // 2. DIÁLOGO DE CONFIRMACIÓN
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmar eliminación"),
                            content: Text("¿Deseas eliminar la serie de ${s.repes} x ${s.peso}kg?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("CANCELAR"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    
                    onDismissed: (direction) {
                      setState(() {
                        widget.ejercicio.series.removeAt(index);
                      });
                      widget.onActualizado();
                    },

                    child: Card(
                      child: ListTile(
                        title: Text('Serie ${index + 1}: ${s.repes} x ${s.peso}kg'),
                        trailing: const Icon(Icons.edit, size: 20),
                        onTap: () => _mostrarDialogoEdicion(index),
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