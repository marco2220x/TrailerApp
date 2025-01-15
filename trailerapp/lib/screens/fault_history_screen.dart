import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaultHistoryScreen extends StatelessWidget {
  final String truckDocumentId;

  const FaultHistoryScreen({Key? key, required this.truckDocumentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verificamos que el truckDocumentId no sea nulo o vacío
    if (truckDocumentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Historial de Fallas'),
        ),
        body: Center(
          child: Text('ID del camión no proporcionado.'),
        ),
      );
    }

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

          // Imprimimos los registros para depuración
          print('Registros de fallas para $truckDocumentId: ${faultRecords.length} encontrados.');

          return ListView.builder(
            itemCount: faultRecords.length,
            itemBuilder: (context, index) {
              final record = faultRecords[index].data() as Map<String, dynamic>;

              // Maneja campos nulos con valores predeterminados
              final String codigo = record['codigo'] ?? 'Sin código';
              final String resultados = record['resultados'] ?? 'Sin resultados';
              final Timestamp? tiempo = record['tiempo'] as Timestamp?;
              final String formattedTime = tiempo != null
                  ? '${tiempo.toDate().day}/${tiempo.toDate().month}/${tiempo.toDate().year} ${tiempo.toDate().hour}:${tiempo.toDate().minute}'
                  : 'Sin fecha';

              return ListTile(
                title: Text(codigo),
                subtitle: Text('Fecha: $formattedTime\nResultados: $resultados'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(codigo),
                      content: Text(
                        'Fecha y hora de consulta: $formattedTime\n\n'
                        'Resultados: ${record['resultados'] ?? 'Sin resultados'}\n'
                        'Acción: ${record['accion'] ?? 'Sin acción'}\n'
                        'Relacion códigos: ${record['relacion_codigos'] ?? 'Sin relación'}',
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
