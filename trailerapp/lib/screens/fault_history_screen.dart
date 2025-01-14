import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore

class FaultHistoryScreen extends StatelessWidget {
  final String truckDocumentId = 'G4F5gx1g0ITQUL0HBvUR';

  @override
  Widget build(BuildContext context) {
    // Referencia a la subcolección "fallas" del camión
    final CollectionReference faultCollection = FirebaseFirestore.instance
        .collection('camiones')
        .doc(truckDocumentId)
        .collection('fallas');

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Fallas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: faultCollection.orderBy('tiempo', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay fallas registradas.'));
          }

          final faultRecords = snapshot.data!.docs;

          return ListView.builder(
            itemCount: faultRecords.length,
            itemBuilder: (context, index) {
              final record = faultRecords[index].data() as Map<String, dynamic>;

              final String codigo = record['codigo'];
              final String resultados = record['resultados'];
              final Timestamp tiempo = record['tiempo'];
              final String formattedTime =
                  '${tiempo.toDate().day}/${tiempo.toDate().month}/${tiempo.toDate().year} ${tiempo.toDate().hour}:${tiempo.toDate().minute}';

              return ListTile(
                title: Text(codigo),
                subtitle:
                    Text('Fecha: $formattedTime\nResultados: $resultados'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(codigo),
                      content: Text(
                        'Fecha y hora de consulta: $formattedTime\n\n'
                        'Resultados: ${record['resultados']}\n'
                        'Acción: ${record['accion']}\n'
                        'Relacion códigos: ${record['relacion_codigos']}\n\n'
                        'Solución: ${record['solucion']}\n',
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
          );
        },
      ),
    );
  }
}
