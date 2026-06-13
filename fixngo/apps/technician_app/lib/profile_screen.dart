
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service_new.dart';
import 'widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _picker = ImagePicker();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  Uint8List? _photoBytes;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final dash = await _api.getDashboard();
    if (!mounted) return;
    setState(() {
      _profile = dash;
      _photoBytes = null;
      _photoUrl = dash?['profilePhoto'] as String?;
      _loading = false;
    });
  }

  Future<void> _updatePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _photoBytes = bytes);

    if (kIsWeb) {
      return;
    }

    final uploaded = await _api.uploadProfilePhoto(image.path);
    if (!mounted) return;

    if (uploaded) {
      final refreshed = await _api.getDashboard();
      final photoUrl = refreshed?['profilePhoto'] as String?;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        setState(() {
          _profile = refreshed;
          _photoUrl = photoUrl;
          _photoBytes = null;
        });
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _miniStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name'] ?? 'Technician';
    final rating = _profile?['rating'] ?? '4.8';
    final jobs = _profile?['jobsDone'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          ),
        ),
        title: const Text('Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _updatePhoto,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.red, width: 2.5),
                                ),
                                child: ClipOval(
                                  child: _photoBytes != null
                                      ? Image.memory(
                                          _photoBytes!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.card,
                                              child: const Icon(Icons.person_rounded, color: AppColors.grey, size: 46),
                                            );
                                          },
                                        )
                                      : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                          ? Image.network(
                                              ApiService.imageUrl(_photoUrl!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: AppColors.card,
                                                  child: const Icon(Icons.person_rounded, color: AppColors.grey, size: 46),
                                                );
                                              },
                                            )
                                      : Container(
                                          color: AppColors.card,
                                          child: const Icon(Icons.person_rounded, color: AppColors.grey, size: 46),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _updatePhoto,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.bg, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Verified Technician', style: TextStyle(color: AppColors.green, fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _miniStat('$rating ★', 'Rating'),
                            Container(width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _miniStat('$jobs', 'Jobs Done'),
                            Container(width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _miniStat('4 yrs', 'Experience'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SectionLabel('Verification'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_rounded, color: AppColors.green),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Aadhaar KYC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              Text('Upload docs and keep your profile verified.', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Specializations'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                        'Screen Replacement',
                      'Battery Fix',
                      'Water Damage',
                      'Charging Port',
                      'Software Issues',
                    ].map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(s, style: const TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Account'),
                  _menuItem(Icons.edit, 'Edit Profile', () => Navigator.pushNamed(context, '/edit_profile')),
                  _menuItem(Icons.document_scanner_rounded, 'Documents & KYC', () => Navigator.pushNamed(context, '/kyc')),
                  _menuItem(Icons.account_balance_rounded, 'Bank Details', () => Navigator.pushNamed(context, '/bank_details')),
                  _menuItem(Icons.notifications_rounded, 'Notification Settings', () => Navigator.pushNamed(context, '/notification_settings')),
                  const SizedBox(height: 16),
                  const SectionLabel('Support'),
                  _menuItem(Icons.help_rounded, 'Help & Support', () => Navigator.pushNamed(context, '/support')),
                  _menuItem(Icons.policy_rounded, 'Privacy Policy', () => Navigator.pushNamed(context, '/privacy')),
                  _menuItem(Icons.gavel_rounded, 'Terms of Service', () => Navigator.pushNamed(context, '/terms')),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: AppColors.red, fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
