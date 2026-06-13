import 'package:flutter/material.dart';
import 'widgets/common_widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newJobs = true;
  bool _jobUpdates = true;
  bool _earnings = false;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Notification Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Job Notifications'),
            _buildToggle(
              'New Job Requests',
              'Get notified when a new job matches your skills.',
              _newJobs,
              (v) => setState(() => _newJobs = v),
            ),
            const SizedBox(height: 16),
            _buildToggle(
              'Job Updates',
              'Notifications about status changes or customer messages.',
              _jobUpdates,
              (v) => setState(() => _jobUpdates = v),
            ),
            const SizedBox(height: 32),
            const SectionLabel('Account & Earnings'),
            _buildToggle(
              'Earnings & Payouts',
              'Get notified when payments are processed or deposited.',
              _earnings,
              (v) => setState(() => _earnings = v),
            ),
            const SizedBox(height: 16),
            _buildToggle(
              'Promotions & News',
              'Updates about Fix-N-Go features and special bonuses.',
              _promotions,
              (v) => setState(() => _promotions = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.green,
            activeTrackColor: AppColors.green.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.grey,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }
}
