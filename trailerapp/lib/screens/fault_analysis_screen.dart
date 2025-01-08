import 'package:flutter/material.dart';

class FaultAnalysisScreen extends StatefulWidget {
  @override
  _FaultAnalysisScreenState createState() => _FaultAnalysisScreenState();
}

class _FaultAnalysisScreenState extends State<FaultAnalysisScreen> {
  final TextEditingController _faultCodeController = TextEditingController();
  final TextEditingController _lampColorController = TextEditingController();

  String? faultReason;
  String? correctiveAction;

  void _analyzeFault() {
    setState(() {
      faultReason = "Turbocharger boost pressure drop detected.";
      correctiveAction = "Schedule a service for inspection.";
    });
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blue),
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
