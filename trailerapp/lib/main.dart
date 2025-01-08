import 'package:flutter/material.dart';
import 'screens/truck_screen.dart';
import 'screens/fault_analysis_screen.dart';
import 'screens/maintenance_centers_screen.dart'; // Importa la nueva pantalla

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truck Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/truck',
      routes: {
        '/truck': (context) => TruckScreen(),
        '/fault-analysis': (context) => FaultAnalysisScreen(),
        '/maintenance-centers': (context) => MaintenanceCentersScreen(), // Nueva ruta
      },
    );
  }
}
