import 'package:flutter/material.dart';
import 'screens/truck_list_screen.dart'; // Nueva pantalla de lista de camiones
import 'screens/truck_screen.dart';
import 'screens/fault_analysis_screen.dart';
import 'screens/maintenance_centers_screen.dart';
import 'screens/fault_history_screen.dart';

//Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  //Firebase configuration
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truck Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => TruckListScreen());
          case '/truck':
            final String truckId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TruckScreen(truckId: truckId),
            );
          case '/fault-analysis':
            final String truckId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) =>
                  FaultAnalysisScreen(truckDocumentId: truckId), // Corregido aquí
            );
          case '/maintenance-centers':
            return MaterialPageRoute(
              builder: (context) => MaintenanceCentersScreen(),
            );
          case '/fault-history':
            final String truckId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) =>
                  FaultHistoryScreen(truckDocumentId: truckId),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Pantalla no encontrada')),
              ),
            );
        }
      },
    );
  }
}
