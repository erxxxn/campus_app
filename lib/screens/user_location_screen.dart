import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  final String providerId;
  final String foodTitle;

  const LocationScreen({
    Key? key,
    required this.providerId,
    required this.foodTitle,
  }) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  LatLng? _providerLocation;
  bool _isLoading = true;
  String _distance = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchProviderLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _fetchProviderLocation() async {
    try {
      // Replace with your actual API endpoint to get provider location
      final response = await http.get(
        Uri.parse('http://172.20.10.4:5000/api/providers/${widget.providerId}/location'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _providerLocation = LatLng(data['latitude'], data['longitude']);
          _isLoading = false;
        });
        _calculateDistance();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: ${e.toString()}')),
      );
    }
  }

  Future<void> _calculateDistance() async {
    if (_currentPosition == null || _providerLocation == null) return;

    double distanceInMeters = await Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _providerLocation!.latitude,
      _providerLocation!.longitude,
    );

    // Estimated walking speed (5 km/h)
    double walkingSpeed = 5000 / 3600; // meters per second
    int durationInMinutes = (distanceInMeters / walkingSpeed / 60).round();

    setState(() {
      _distance = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
      _duration = '$durationInMinutes min walk';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Directions to ${widget.foodTitle}'),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _providerLocation ?? const LatLng(3.1390, 101.6869), // Default to KL coordinates
                      zoom: 15,
                    ),
                    markers: {
                      if (_currentPosition != null)
                        Marker(
                          markerId: const MarkerId('current_location'),
                          position: _currentPosition!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                          infoWindow: const InfoWindow(title: 'Your Location'),
                        ),
                      if (_providerLocation != null)
                        Marker(
                          markerId: const MarkerId('provider_location'),
                          position: _providerLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange),
                          infoWindow: InfoWindow(title: '${widget.foodTitle} Location'),
                        ),
                    },
                    polylines: {
                      if (_currentPosition != null && _providerLocation != null)
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: [_currentPosition!, _providerLocation!],
                          color: Colors.orange,
                          width: 4,
                        ),
                    },
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DISTANCE',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey)),
                          Text(_distance,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DURATION',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey)),
                          Text(_duration,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_providerLocation != null) {
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(_providerLocation!),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Navigate',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}