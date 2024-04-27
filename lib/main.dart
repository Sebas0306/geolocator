import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para cambiar el idioma de la aplicación
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Distancia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, String>> locations = [
    {'name': 'Ubicación 1', 'latitude': '40.7128', 'longitude': '-74.0060'},
    {'name': 'Ubicación 2', 'latitude': '34.0522', 'longitude': '-118.2437'},
    {'name': 'Ubicación 3', 'latitude': '51.5074', 'longitude': '-0.1278'},
    {'name': 'Ubicación 4', 'latitude': '48.8566', 'longitude': '2.3522'},
    {'name': 'Ubicación 5', 'latitude': '35.6895', 'longitude': '139.6917'},
  ];

  String? selectedLocation;
  double distance = 0.0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      print('El usuario negó los permisos de ubicación');
    }
  }

  Future<void> _calculateDistance(String latitude, String longitude) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distanceInMeters = await _calculateDistanceInMeters(
        position.latitude,
        position.longitude,
        double.parse(latitude),
        double.parse(longitude));

    setState(() {
      distance = distanceInMeters / 1000;
    });
  }

  Future<double> _calculateDistanceInMeters(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) async {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLong = _degreesToRadians(endLongitude - startLongitude);
    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            pow(sin(dLong / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Distancia'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return ListTile(
                  title: Text(
                    '${location['name']} (${location['latitude']}, ${location['longitude']})',
                    style: TextStyle(
                      fontWeight: selectedLocation == location['name']
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedLocation = location['name'];
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: selectedLocation == null
                ? null
                : () {
                    final location = locations.firstWhere(
                      (element) => element['name'] == selectedLocation,
                      orElse: () => {},
                    );
                    if (location!.isNotEmpty) {
                      _calculateDistance(
                        location['latitude']!,
                        location['longitude']!,
                      );
                    }
                  },
            child: Text('Calcular distancia'),
          ),
          SizedBox(height: 16),
          Text(
            'Selecciona una ubicación y luego pulsa el botón "Calcular distancia"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          if (selectedLocation != null)
            Column(
              children: [
                Text(
                  'Distancia a $selectedLocation:',
                ),
                Text(
                  '${distance.toStringAsFixed(2)} km',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
