import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'dart:async';

class LiveTrackingScreen extends StatefulWidget {
  final String orderId;
  final double customerLat;
  final double customerLng;
  final String customerAddress;

  const LiveTrackingScreen({
    required this.orderId,
    required this.customerLat,
    required this.customerLng,
    required this.customerAddress,
    Key? key,
  }) : super(key: key);

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  double? technicianLat;
  double? technicianLng;
  double? distance;
  String? eta;
  bool isLoading = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  void _startLocationTracking() {
    // Update location every 5 seconds
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _updateTechnicianLocation();
    });
  }

  Future<void> _updateTechnicianLocation() async {
    try {
      final token = await _storageService.getToken();
      
      // Get current location (mock for now)
      final currentLat = widget.customerLat + (0.01 * (DateTime.now().millisecond % 10) / 10);
      final currentLng = widget.customerLng + (0.01 * (DateTime.now().millisecond % 10) / 10);

      // Update location on backend
      await _apiService.post(
        '/location/update-location',
        {
          'latitude': currentLat,
          'longitude': currentLng,
        },
      );

      // Get route details
      final routeResponse = await _apiService.post(
        '/location/route',
        {
          'startLat': currentLat,
          'startLng': currentLng,
          'endLat': widget.customerLat,
          'endLng': widget.customerLng,
        },
      );

      if (routeResponse['success']) {
        final data = routeResponse['data'];
        setState(() {
          technicianLat = currentLat;
          technicianLng = currentLng;
          distance = (data['distanceValue'] as num?)?.toDouble() ?? 0;
          eta = data['duration'] ?? 'Calculating...';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error tracking technician: $e');
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technician En Route',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1A56FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map Container (Mock)
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[200],
                    child: Stack(
                      children: [
                        // Mock map background
                        Center(
                          child: Text(
                            '📍 Live Map View\n(Google Maps Integration)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        // Technician location marker
                        if (technicianLat != null && technicianLng != null)
                          Positioned(
                            left: 100,
                            top: 120,
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1A56FF),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Technician',
                                  style: GoogleFonts.poppins(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        // Customer location marker
                        Positioned(
                          right: 80,
                          bottom: 80,
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'You',
                                style: GoogleFonts.poppins(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ETA and Distance
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFE0F0FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF1A56FF), width: 2),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: Color(0xFF1A56FF),
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'ETA',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                eta ?? 'Calculating...',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A56FF),
                                ),
                              ),
                            ],
                          ),
                          VerticalDivider(thickness: 2),
                          Column(
                            children: [
                              Icon(
                                Icons.distance,
                                color: Color(0xFF1A56FF),
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'DISTANCE',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                distance != null
                                    ? _formatDistance(distance!)
                                    : 'Calculating...',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A56FF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Destination Details
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Location',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: Colors.red),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.customerAddress,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Lat: ${widget.customerLat.toStringAsFixed(4)}, Lng: ${widget.customerLng.toStringAsFixed(4)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Call Technician Button
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling technician...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Icon(Icons.call, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
