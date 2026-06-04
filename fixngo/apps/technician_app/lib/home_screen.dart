import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  List<dynamic> _jobs = [];
  bool _loading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    // Start offline by default
    _apiService.updateLocation(0, 0, false); 
  }

  Future<void> _updateStatus(bool online) async {
    setState(() => _isOnline = online);
    if (!online) {
      await _apiService.updateLocation(0, 0, false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isOnline = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isOnline = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _apiService.updateLocation(position.latitude, position.longitude, true);
  }

  Future<void> _fetchJobs() async {
    setState(() => _loading = true);
    final jobs = await _apiService.getAvailableJobs();
    setState(() {
      _jobs = jobs;
      _loading = false;
    });
  }

  void _acceptJob(String id) async {
    bool success = await _apiService.acceptJob(id);
    if (success) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job accepted!')));
      _fetchJobs();
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to accept job.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(_isOnline ? 'Online' : 'Offline', style: const TextStyle(fontSize: 12)),
              Switch(
                value: _isOnline,
                onChanged: _updateStatus,
                activeColor: Colors.greenAccent,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () => Navigator.pushNamed(context, '/my_jobs'),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => Navigator.pushNamed(context, '/earnings'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _jobs.isEmpty 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No jobs available right now.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              )
            )
          : ListView.builder(
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                final job = _jobs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(job['serviceType'] ?? 'General Repair', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Distance: ${job['distance'] != null ? job['distance'].toStringAsFixed(1) : '?'} km'),
                        Text('Est. Price: \$${job['estimatedPrice'] ?? '?'}'),
                      ]
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () => _acceptJob(job['_id']),
                      child: const Text('ACCEPT'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
