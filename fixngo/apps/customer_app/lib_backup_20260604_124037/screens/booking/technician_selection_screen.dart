import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class TechnicianSelectionScreen extends StatefulWidget {
  final String orderId;
  final double lat;
  final double lng;
  final String? serviceAddress;

  const TechnicianSelectionScreen({
    required this.orderId,
    required this.lat,
    required this.lng,
    this.serviceAddress,
    Key? key,
  }) : super(key: key);

  @override
  _TechnicianSelectionScreenState createState() =>
      _TechnicianSelectionScreenState();
}

class _TechnicianSelectionScreenState extends State<TechnicianSelectionScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<dynamic> nearbyTechs = [];
  bool isLoading = true;
  String? selectedTechId;

  @override
  void initState() {
    super.initState();
    _loadNearbyTechs();
  }

  Future<void> _loadNearbyTechs() async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.post(
        '/location/nearby-orders',
        {
          'latitude': widget.lat,
          'longitude': widget.lng,
          'radiusKm': 50,
        },
      );

      if (response['success']) {
        // In real app, this would return available technicians
        // For now, mock some technician data
        setState(() {
          nearbyTechs = [
            {
              'id': 'tech_1',
              'name': 'Rajesh Kumar',
              'rating': 4.8,
              'reviews': 234,
              'distance': 2.5,
              'experience': '5 years',
              'services': ['Phone Repair', 'Laptop Service'],
              'available': true,
            },
            {
              'id': 'tech_2',
              'name': 'Priya Singh',
              'rating': 4.9,
              'reviews': 189,
              'distance': 3.2,
              'experience': '4 years',
              'services': ['Phone Repair', 'Tablet Service'],
              'available': true,
            },
            {
              'id': 'tech_3',
              'name': 'Arjun Patel',
              'rating': 4.7,
              'reviews': 156,
              'distance': 4.1,
              'experience': '6 years',
              'services': ['Laptop Service', 'Desktop Service'],
              'available': true,
            },
            {
              'id': 'tech_4',
              'name': 'Neha Sharma',
              'rating': 4.6,
              'reviews': 98,
              'distance': 5.8,
              'experience': '3 years',
              'services': ['Phone Repair', 'Data Recovery'],
              'available': false,
            },
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading technicians: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _selectTechnician(String techId) {
    setState(() => selectedTechId = techId);
  }

  Future<void> _confirmSelection() async {
    if (selectedTechId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a technician')),
      );
      return;
    }

    // Here you would typically call an API to assign the technician
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Technician assigned successfully!')),
    );
    Navigator.pop(context, selectedTechId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Technician',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1A56FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info Banner
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0F0FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF1A56FF)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Color(0xFF1A56FF)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose a nearby technician for your order',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Color(0xFF1A56FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Technicians List
                Expanded(
                  child: ListView.builder(
                    itemCount: nearbyTechs.length,
                    itemBuilder: (context, index) {
                      final tech = nearbyTechs[index];
                      final isSelected = selectedTechId == tech['id'];
                      final isAvailable = tech['available'] ?? true;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: isAvailable
                              ? () => _selectTechnician(tech['id'])
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFF1A56FF)
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? Color(0xFFF5F5FF)
                                  : (isAvailable ? Colors.white : Colors.grey[100]),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(0xFF1A56FF).withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1A56FF),
                                      ),
                                      child: Center(
                                        child: Text(
                                          tech['name']
                                              .toString()
                                              .split(' ')
                                              .map((e) => e[0])
                                              .join(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                tech['name'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (!isAvailable)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        4,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Unavailable',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${tech['rating']} (${tech['reviews']} reviews)',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${tech['distance']}km away • ${tech['experience']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Selection indicator
                                    if (isSelected)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF1A56FF),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Services
                                Wrap(
                                  spacing: 4,
                                  children: (tech['services'] as List)
                                      .map(
                                        (service) => Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE0F0FF),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            service,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Color(0xFF1A56FF),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Confirm Button
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: selectedTechId != null ? _confirmSelection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A56FF),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Confirm Selection',
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
