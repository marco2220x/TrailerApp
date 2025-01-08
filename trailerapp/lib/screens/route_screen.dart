import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class RouteScreen extends StatefulWidget {
  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  List<LatLng> _routePoints = [];
  bool _isRouteActive = false;

  // Coordenadas para Ciudad de México y Puebla
  static const LatLng _startLocation = LatLng(19.432608, -99.133209); // Ciudad de México
  static const LatLng _endLocation = LatLng(19.041296, -98.206283); // Puebla

  final String _openRouteServiceApiKey = '5b3ce3597851110001cf62486d87929fc8724ec6a10783e887949758'; // Reemplaza con tu clave de OpenRouteService

  // Función para obtener y mostrar la ruta desde la API de OpenRouteService
  Future<void> _startRoute() async {
    try {
      final routePoints = await getRoutePoints(
        '${_startLocation.longitude},${_startLocation.latitude}', // Longitud, Latitud para OpenRouteService
        '${_endLocation.longitude},${_endLocation.latitude}', // Longitud, Latitud para OpenRouteService
      );
      setState(() {
        _routePoints = routePoints;
        _isRouteActive = true;
      });
    } catch (e) {
      print("Error al obtener la ruta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener la ruta: $e")),
      );
    }
  }

  // Función para detener la ruta
  void _endRoute() {
    setState(() {
      _routePoints = [];
      _isRouteActive = false;
    });
  }

  // Obtener puntos de la API de OpenRouteService
  Future<List<LatLng>> getRoutePoints(String start, String end) async {
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$_openRouteServiceApiKey&start=$start&end=$end';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_openRouteServiceApiKey',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final polyline = data['features'][0]['geometry']['coordinates'];
        return decodePolyline(polyline);
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
      rethrow;
    }
  }

  // Decodificar la polyline de OpenRouteService
  List<LatLng> decodePolyline(List<dynamic> encoded) {
    List<LatLng> points = [];
    for (var point in encoded) {
      points.add(LatLng(point[1], point[0]));  // OJO: la latitud y longitud están invertidas
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Ruta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _startLocation,
              zoom: 6,
            ),
            polylines: {
              if (_routePoints.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: _routePoints,
                ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('start'),
                position: _startLocation,
                infoWindow: const InfoWindow(title: 'Start: Ciudad de México'),
              ),
              Marker(
                markerId: const MarkerId('end'),
                position: _endLocation,
                infoWindow: const InfoWindow(title: 'End: Puebla'),
              ),
            },
            onMapCreated: (controller) => _mapController.complete(controller),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isRouteActive ? null : _startRoute,
                    child: const Text('Iniciar Ruta'),
                  ),
                  ElevatedButton(
                    onPressed: _isRouteActive ? _endRoute : null,
                    child: const Text('Finalizar Ruta'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
