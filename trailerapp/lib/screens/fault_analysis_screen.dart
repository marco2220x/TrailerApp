import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore

class FaultAnalysisScreen extends StatefulWidget {
  final String truckDocumentId = 'G4F5gx1g0ITQUL0HBvUR';

  @override
  _FaultAnalysisScreenState createState() => _FaultAnalysisScreenState();
}

class _FaultAnalysisScreenState extends State<FaultAnalysisScreen> {
  final TextEditingController _faultCodeController = TextEditingController();
  final TextEditingController _lampColorController = TextEditingController();

  String? faultReason;
  String? correctiveAction;

  // Método para analizar la falla (muestra resultados estáticos)
  void _analyzeFault() {
    setState(() {
      faultReason =
          "Turbocharger boost pressure drop detected."; // Resultado estático
      correctiveAction =
          "Schedule a service for inspection."; // Acción estática
    });

    // Guardar en Firestore
    _saveFaultRecord();
  }

  // Método para guardar los datos en Firestore
  void _saveFaultRecord() async {
    // Referencia a la subcolección 'fallas' del camión con el ID proporcionado
    final faultCollection = FirebaseFirestore.instance
        .collection('camiones')
        .doc(widget.truckDocumentId)
        .collection('fallas');

    // Crear un nuevo documento con los datos del análisis
    await faultCollection.add({
      'codigo': _faultCodeController
          .text, // El código de falla ingresado por el usuario
      'resultados':
          faultReason ?? '', // Resultado de análisis (razón de la falla)
      'accion': correctiveAction ?? '', // Acción correctiva
      'relacion_codigos':
          'Posibles relaciones', // Este campo estático como ejemplo
      'tiempo': FieldValue.serverTimestamp(), // Fecha y hora de la consulta
      'mecanico': '', // Dejamos vacío para llenar más tarde
      'solucion': '', // Dejamos vacío para llenar más tarde
    });

    // Opcional: Mostrar un mensaje confirmando que el registro fue guardado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Análisis guardado exitosamente')),
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
