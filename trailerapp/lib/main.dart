import 'package:flutter/material.dart';
import 'screens/truck_screen.dart';
import 'screens/fault_analysis_screen.dart';
import 'screens/maintenance_centers_screen.dart';
import 'screens/fault_history_screen.dart'; // Importa la nueva pantalla

//Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  //Firebase configuration
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Usar debugShowCheckedModeBanner para desactivar la etiqueta DEBUG
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
        '/maintenance-centers': (context) => MaintenanceCentersScreen(),
        '/fault-history': (context) => FaultHistoryScreen(), // Nueva ruta
      },
    );
  }
}
