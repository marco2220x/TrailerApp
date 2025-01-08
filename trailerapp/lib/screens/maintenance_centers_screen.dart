import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MaintenanceCentersScreen extends StatefulWidget {
  @override
  _MaintenanceCentersScreenState createState() => _MaintenanceCentersScreenState();
}

class _MaintenanceCentersScreenState extends State<MaintenanceCentersScreen> {
  LatLng? _currentLocation;
  final Location _locationService = Location();
  bool _isLoadingLocation = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
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

      final hasPermission = await _locationService.requestPermission();
      if (hasPermission == PermissionStatus.granted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centros de mantenimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context); // Vuelve al inicio
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa con ubicación actual
          Stack(
            children: [
              Container(
                height: 300,
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
                              Marker(
                                markerId: const MarkerId('penske'),
                                position: const LatLng(37.7749, -122.4194),
                                infoWindow: const InfoWindow(title: 'Penske Truck Rental'),
                              ),
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
              ),
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged: (value) {
                      // Lógica de búsqueda
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                MaintenanceCenterCard(
                  imageUrl: 'assets/images/penske.jpg',
                  title: 'Mecánico Juan',
                  status: 'Abierto · Cierre 5:00 PM',
                  description: 'Agencia de reparación',
                ),
                MaintenanceCenterCard(
                  imageUrl: 'assets/images/loves.jpg',
                  title: 'Mecánico Dominguez',
                  status: 'Abierto · Cierre 8:00 PM',
                  description: 'Reparación',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MaintenanceCenterCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String status;
  final String description;

  const MaintenanceCenterCard({
    required this.imageUrl,
    required this.title,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status, style: TextStyle(color: Colors.green[700])),
            Text(description),
          ],
        ),
        onTap: () {
          // Acción al presionar en el centro
        },
      ),
    );
  }
}
