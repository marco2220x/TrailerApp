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

      PermissionStatus permissionStatus = await _locationService.requestPermission();
      if (permissionStatus == PermissionStatus.granted) {
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

  Future<void> _getCityNames() async {
    try {
      List<Placemark> startPlacemark = await placemarkFromCoordinates(
        19.432608, -99.133209, // Coordenadas de la Ciudad de México
      );
      List<Placemark> endPlacemark = await placemarkFromCoordinates(
        19.041296, -98.206283, // Coordenadas de Puebla
      );

      setState(() {
        _startCity = startPlacemark.first.locality ?? 'San Francisco';
        _endCity = endPlacemark.first.locality ?? 'Los Angeles';
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
            _buildSection(
              title: 'Ruta',
              subtitle: '$_startCity a $_endCity',
              icon: Icons.arrow_forward,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RouteScreen()),
              ),
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'Análisis de Fallas',
              subtitle: 'Ingresar los códigos de falla para un diagnóstico',
              icon: Icons.arrow_forward,
              onTap: () => Navigator.pushNamed(context, '/fault-analysis'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'Centros de Mantenimiento',
              subtitle: 'Ubicar centros de mantenimiento cercanos',
              icon: Icons.location_on,
              onTap: () => Navigator.pushNamed(context, '/maintenance-centers'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'Historial de Fallas',
              subtitle: 'Revisar el historial de errores detectados',
              icon: Icons.history,
              onTap: () => Navigator.pushNamed(context, '/fault-history'),
            ),
            const SizedBox(height: 20),

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

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(icon),
      onTap: onTap,
    );
  }
}
