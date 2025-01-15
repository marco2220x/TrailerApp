import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaultAnalysisScreen extends StatefulWidget {
  final String truckDocumentId; // Recibimos truckId como parámetro

  const FaultAnalysisScreen({Key? key, required this.truckDocumentId})
      : super(key: key);

  @override
  _FaultAnalysisScreenState createState() => _FaultAnalysisScreenState();
}

class _FaultAnalysisScreenState extends State<FaultAnalysisScreen> {
  final TextEditingController _faultCodeController = TextEditingController();
  final TextEditingController _lampColorController = TextEditingController();

  String? faultReason;
  String? correctiveAction;

  // Método para analizar la falla
  void _analyzeFault() {
    if (_faultCodeController.text.trim().isEmpty ||
        _lampColorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      faultReason = "Turbocharger boost pressure drop detected.";
      correctiveAction = "Schedule a service for inspection.";
    });

    // Guardar en Firestore con widget.truckDocumentId
    _saveFaultRecord();
  }

  void _saveFaultRecord() async {
    final faultCollection = FirebaseFirestore.instance
        .collection('camiones')
        .doc(widget.truckDocumentId) // Usamos el truckId pasado al constructor
        .collection('fallas');

    await faultCollection.add({
      'codigo': _faultCodeController.text,
      'resultados': faultReason ?? '',
      'accion': correctiveAction ?? '',
      'relacion_codigos': 'Posibles relaciones',
      'tiempo': FieldValue.serverTimestamp(),
      'mecanico': '',
      'solucion': '',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Análisis guardado exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de fallas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Realizar Análisis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _faultCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de falla',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lampColorController,
                decoration: const InputDecoration(
                  labelText: 'Color de la lámpara',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyzeFault,
                  child: const Text('Analizar'),
                ),
              ),
              const SizedBox(height: 20),
              if (faultReason != null && correctiveAction != null) ...[
                const Text(
                  'Resultados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Razón: $faultReason',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Acción: $correctiveAction',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
