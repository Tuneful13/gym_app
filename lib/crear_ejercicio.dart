import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';
import 'muscle_diagram.dart';

const List<String> todosLosGrupos = [
  'Pecho', 'Hombro', 'Triceps', 'Espalda', 'Biceps', 'Pierna', 'Core'
];

class CrearEjercicio extends StatefulWidget {
  final Ejercicio? ejercicioExistente; // null = crear, non-null = editar
  final Function(Ejercicio) onGuardado;

  const CrearEjercicio({
    super.key,
    this.ejercicioExistente,
    required this.onGuardado,
  });

  @override
  State<CrearEjercicio> createState() => _CrearEjercicioState();
}

class _CrearEjercicioState extends State<CrearEjercicio> {
  final _nombreCtrl = TextEditingController();
  String? _grupoSeleccionado;
  List<String> _principales = [];
  List<String> _secundarios = [];
  File? _imagenSeleccionada;
  final _picker = ImagePicker();

  bool get _esEdicion => widget.ejercicioExistente != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final e = widget.ejercicioExistente!;
      _nombreCtrl.text = e.nombre;
      _grupoSeleccionado = e.grupo;
      _principales = List.from(e.musculosPrincipales);
      _secundarios = List.from(e.musculosSecundarios);
      if (e.imagenPersonalizada != null) {
        _imagenSeleccionada = File(e.imagenPersonalizada!);
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _imagenSeleccionada = File(picked.path));
    }
    if (mounted) Navigator.pop(context); // cierra el diálogo de fuente
  }

  void _mostrarSelectorFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => _seleccionarImagen(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => _seleccionarImagen(ImageSource.gallery),
            ),
            if (_imagenSeleccionada != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _imagenSeleccionada = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _toggleMusculo(String id, String tipo) {
    setState(() {
      if (tipo == 'principal') {
        if (_principales.contains(id)) {
          _principales.remove(id);
        } else {
          _principales.add(id);
          _secundarios.remove(id);
        }
      } else {
        if (_secundarios.contains(id)) {
          _secundarios.remove(id);
        } else {
          _secundarios.add(id);
          _principales.remove(id);
        }
      }
    });
  }

  String _getEstado(String id) {
    if (_principales.contains(id)) return 'principal';
    if (_secundarios.contains(id)) return 'secundario';
    return 'none';
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }
    if (_grupoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un grupo muscular')),
      );
      return;
    }

    final ejercicio = Ejercicio(
      _nombreCtrl.text.trim(),
      '',
      _grupoSeleccionado!,
      _esEdicion ? widget.ejercicioExistente!.series : [],
      musculosPrincipales: List.from(_principales),
      musculosSecundarios: List.from(_secundarios),
      esPersonalizado: true,
      imagenPersonalizada: _imagenSeleccionada?.path,
    );

    widget.onGuardado(ejercicio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar ejercicio' : 'Nuevo ejercicio'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Foto ──────────────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _mostrarSelectorFoto,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imagenSeleccionada != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 32, color: Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text('Añadir foto', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Nombre ────────────────────────────────────────────────────────
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del ejercicio',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 20),

          // ── Grupo muscular ────────────────────────────────────────────────
          const Text('Grupo muscular',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: todosLosGrupos.map((grupo) {
              final seleccionado = _grupoSeleccionado == grupo;
              return ChoiceChip(
                label: Text(grupo),
                selected: seleccionado,
                onSelected: (_) => setState(() => _grupoSeleccionado = grupo),
                selectedColor: Colors.blue.shade900,
                labelStyle: TextStyle(
                  color: seleccionado ? Colors.white : null,
                  fontWeight: seleccionado ? FontWeight.bold : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ── Músculos ──────────────────────────────────────────────────────
          const Text('Músculos trabajados',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Toca para activar/desactivar',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 12),

          // Diagrama en vivo
          SizedBox(
            height: 220,
            child: MuscleDiagram(
              principales: _principales,
              secundarios: _secundarios,
            ),
          ),

          const SizedBox(height: 16),

          // Lista de músculos
          ...todosLosMusculosInfo.map((m) {
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
                  GestureDetector(
                    onTap: () => _toggleMusculo(id, 'principal'),
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
                  GestureDetector(
                    onTap: () => _toggleMusculo(id, 'secundario'),
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
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}