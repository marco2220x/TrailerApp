import 'package:flutter/material.dart';
import '../models/fault_record.dart';
import '../mock_data/mock_fault_records.dart';

class FaultHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<FaultRecord> faultRecords = mockFaultRecords;

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Fallas'),
      ),
      body: ListView.builder(
        itemCount: faultRecords.length,
        itemBuilder: (context, index) {
          final record = faultRecords[index];
          return ListTile(
            title: Text('${record.faultDescription} (${record.faultCode})'), // Incluimos el código
            subtitle: Text(
                'Fecha: ${record.date}\nMecánico: ${record.mechanicName}\nCosto: \$${record.cost.toStringAsFixed(2)}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('${record.faultDescription} (${record.faultCode})'),
                  content: Text(
                    'Solución: ${record.solution}\n'
                    'Piezas cambiadas: ${record.changedParts.join(', ')}\n'
                    // Notas eliminadas
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
