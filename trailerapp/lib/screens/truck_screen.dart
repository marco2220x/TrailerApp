import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';
import 'route_screen.dart';

class TruckScreen extends StatefulWidget {
  @override
  _TruckScreenState createState() => _TruckScreenState();
}

class _TruckScreenState extends State<TruckScreen> {
  LatLng? _currentLocation; // Coordenadas actuales
  final Location _locationService = Location();
  bool _isLoadingLocation = true; // Indicador de carga para ubicación
  String? _errorMessage; // Mensaje de error
  String _startCity = 'San Francisco'; // Ciudad de inicio
  String _endCity = 'Los Angeles'; // Ciudad de destino

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _getCityNames();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLoadingLocation = false;
            _errorMessage = "Por favor, habilita los servicios de ubicación.";
          });
          return;
        }
      }

      // Solicitar permisos para acceder a la ubicación
      final hasPermission = await _locationService.requestPermission();
      if (hasPermission == PermissionStatus.granted) {
        // Obtener la ubicación actual
        final locationData = await _locationService.getLocation();
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _isLoadingLocation = false;
          _errorMessage = "Permisos denegados para acceder a la ubicación.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = "Error obteniendo la ubicación: $e";
      });
    }
  }

  // Función para obtener los nombres de las ciudades a partir de las coordenadas
  Future<void> _getCityNames() async {
    try {
      // Obtener los nombres de las ciudades para el punto de inicio
      List<Placemark> startPlacemark = await placemarkFromCoordinates(
        19.432608, -99.133209, // Coordenadas de la Ciudad de México
      );
      List<Placemark> endPlacemark = await placemarkFromCoordinates(
        19.041296, -98.206283, // Coordenadas de Puebla
      );

      setState(() {
        _startCity = startPlacemark.first.locality ?? 'San Francisco'; // Nombre de la ciudad de inicio
        _endCity = endPlacemark.first.locality ?? 'Los Angeles'; // Nombre de la ciudad de destino
      });
    } catch (e) {
      print("Error al obtener las ciudades: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truck 12345'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Acción para configuración
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ruta
            const Text(
              'Ruta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Ver Ruta'),
              subtitle: Text('$_startCity a $_endCity'), // Se muestran las ciudades dinámicamente
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RouteScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Análisis de fallas
            const Text(
              'Análisis de Fallas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Analizar fallas'),
              subtitle: const Text('Ingresar los códigos de falla para un diagnóstico'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, '/fault-analysis');
              },
            ),
            const SizedBox(height: 20),

            // Centros de mantenimiento
            const Text(
              'Centros de Mantenimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Encontrar Centros Cercanos'),
              subtitle: const Text('Ubicar centros de mantenimiento cercanos'),
              trailing: const Icon(Icons.location_on),
              onTap: () {
                Navigator.pushNamed(context, '/maintenance-centers'); // Redirige a la nueva pantalla
              },
            ),
            const SizedBox(height: 20),

            // Mapa
            const Text(
              'Tu ubicación actual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey),
              ),
              child: _isLoadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation!,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('current_location'),
                              position: _currentLocation!,
                              infoWindow: const InfoWindow(title: 'Estás aquí'),
                            ),
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
