import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'truck_screen.dart'; // Importa tu pantalla TruckScreen

class TruckListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CollectionReference truckCollection =
        FirebaseFirestore.instance.collection('camiones');

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Camiones'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: truckCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay camiones registrados.'));
          }

          final trucks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trucks.length,
            itemBuilder: (context, index) {
              final truck = trucks[index].data() as Map<String, dynamic>;
              final String truckId = trucks[index].id;
              final String nombre = truck['nombre'];
              final String modelo = truck['modelo'];

              return ListTile(
                title: Text(nombre),
                subtitle: Text('Modelo: $modelo'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TruckScreen(truckId: truckId),
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
