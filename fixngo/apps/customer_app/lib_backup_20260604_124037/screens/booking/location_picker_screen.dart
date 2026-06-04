import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;
  
  const LocationPickerScreen({
    required this.onLocationSelected,
    Key? key,
  }) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<dynamic> suggestions = [];
  bool isLoading = false;
  double? selectedLat;
  double? selectedLng;
  String? selectedAddress;

  void _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await _apiService.post(
        '/location/suggestions',
        {'input': query},
      );

      if (response['success']) {
        setState(() => suggestions = response['data']['suggestions'] ?? []);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching locations: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _selectLocation(String placeId, String description) async {
    setState(() => isLoading = true);

    try {
      final response = await _apiService.post(
        '/location/place-details',
        {'placeId': placeId},
      );

      if (response['success']) {
        final data = response['data'];
        setState(() {
          selectedLat = data['latitude'];
          selectedLng = data['longitude'];
          selectedAddress = data['address'] ?? description;
          _searchController.text = selectedAddress ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location details: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _confirmLocation() {
    if (selectedLat != null && selectedLng != null && selectedAddress != null) {
      widget.onLocationSelected(selectedLat!, selectedLng!, selectedAddress!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Location',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1A56FF),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocations,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: Icon(Icons.location_on),
                suffixIcon: isLoading ? SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (selectedLat != null && selectedLng != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFE0F0FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF1A56FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A56FF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      selectedAddress ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lat: ${selectedLat?.toStringAsFixed(4)}, Lng: ${selectedLng?.toStringAsFixed(4)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text(
                    suggestion['description'] ?? '',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () => _selectLocation(
                    suggestion['place_id'] ?? '',
                    suggestion['description'] ?? '',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedLat != null ? _confirmLocation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A56FF),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Confirm Location',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
