import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteScreen extends StatefulWidget {
  final String truckDocumentId;

  RouteScreen({required this.truckDocumentId});

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  List<LatLng> _routePoints = [];
  bool _isRouteActive = false;
  LatLng? _startLocation;
  LatLng? _endLocation;

  final String _openRouteServiceApiKey =
      '5b3ce3597851110001cf62486d87929fc8724ec6a10783e887949758';

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
  }

  // Fetch coordinates from Firestore
  Future<void> _fetchCoordinates() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('camiones')
          .doc(widget.truckDocumentId)
          .get();

      if (doc.exists) {
        GeoPoint startGeoPoint = doc['ubic_inicio'];
        GeoPoint endGeoPoint = doc['ubic_final'];

        setState(() {
          _startLocation =
              LatLng(startGeoPoint.latitude, startGeoPoint.longitude);
          _endLocation = LatLng(endGeoPoint.latitude, endGeoPoint.longitude);
        });
      } else {
        throw Exception('Documento no encontrado en Firestore');
      }
    } catch (e) {
      print("Error al obtener las coordenadas: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener las coordenadas: $e")),
      );
    }
  }

  Future<void> _startRoute() async {
    if (_startLocation == null || _endLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las coordenadas no están disponibles"),
        ),
      );
      return;
    }

    try {
      final routePoints = await getRoutePoints(
        '${_startLocation!.longitude},${_startLocation!.latitude}',
        '${_endLocation!.longitude},${_endLocation!.latitude}',
      );
      setState(() {
        _routePoints = routePoints;
        _isRouteActive = true;
      });
    } catch (e) {
      print("Error al iniciar la ruta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar la ruta: $e")),
      );
    }
  }

  void _endRoute() {
    setState(() {
      _routePoints = [];
      _isRouteActive = false;
    });
  }

  Future<List<LatLng>> getRoutePoints(String start, String end) async {
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$_openRouteServiceApiKey&start=$start&end=$end';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final polyline = data['features'][0]['geometry']['coordinates'];
        return decodePolyline(polyline);
      } else {
        throw Exception('Error al obtener la ruta: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al obtener puntos de ruta: $e");
      rethrow;
    }
  }

  List<LatLng> decodePolyline(List<dynamic> encoded) {
    return encoded
        .map((point) => LatLng(point[1], point[0]))
        .toList(); // Invertimos latitud y longitud
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
            initialCameraPosition: CameraPosition(
              target: _startLocation ?? const LatLng(19.432608, -99.133209),
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
              if (_startLocation != null)
                Marker(
                  markerId: const MarkerId('start'),
                  position: _startLocation!,
                  infoWindow: const InfoWindow(title: 'Inicio'),
                ),
              if (_endLocation != null)
                Marker(
                  markerId: const MarkerId('end'),
                  position: _endLocation!,
                  infoWindow: const InfoWindow(title: 'Fin'),
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
