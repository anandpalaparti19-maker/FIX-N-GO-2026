import 'package:flutter/material.dart';

import 'api_service_new.dart';
import 'widgets/common_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _api = ApiService();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  int? _openFaq;
  bool _loading = true;
  bool _submitting = false;
  String _category = 'general';
  String _priority = 'medium';
  List<dynamic> _tickets = [];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I get more job requests?',
      'a': 'Stay online and maintain a high rating. Jobs are assigned based on proximity, rating, and acceptance rate. Keep your profile updated with all relevant skills.',
    },
    {
      'q': 'When will my earnings be credited?',
      'a': 'Earnings are credited to your wallet immediately after job completion. Withdrawals to bank usually take 1-2 business days.',
    },
    {
      'q': 'What if the customer is not available?',
      'a': 'Try calling the customer. If unreachable after 10 minutes of arrival, you can mark the job as a "No Show" from the job details screen.',
    },
    {
      'q': 'How is my rating calculated?',
      'a': 'Your rating is the average of all customer ratings over the past 30 days. Completing jobs quickly and professionally improves your rating.',
    },
    {
      'q': 'Can I cancel an accepted job?',
      'a': 'Cancellations affect your acceptance rate. Use this sparingly. If you must cancel, do so 10+ minutes before the scheduled time.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final tickets = await _api.getMySupportTickets();
    if (!mounted) return;
    setState(() {
      _tickets = tickets;
      _loading = false;
    });
  }

  Future<void> _submitTicket() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_subjectCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both subject and message'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final success = await _api.createSupportTicket(
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      category: _category,
      priority: _priority,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      _subjectCtrl.clear();
      _messageCtrl.clear();
      await _loadTickets();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Support request sent'), backgroundColor: AppColors.green),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to send support request'), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Contact Us'),
            Row(
              children: [
                Expanded(
                  child: _contactCard(
                    Icons.headset_mic_rounded,
                    'Call Support',
                    '24/7 Available',
                    AppColors.orange,
                    () => _showSupportHelp('Call Support', 'Please call customer support for urgent assistance.'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _contactCard(
                    Icons.chat_rounded,
                    'Live Chat',
                    'Avg 2 min reply',
                    AppColors.green,
                    () => _showSupportHelp('Live Chat', 'Chat with support on WhatsApp or via the app inbox.'),
                  ),
                ),
              ],
            ),
              const SectionLabel('Raise a Request'),
              TextField(
                controller: _subjectCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Subject',
                  prefixIcon: Icon(Icons.subject_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageCtrl,
                minLines: 4,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Describe your issue',
                  prefixIcon: Icon(Icons.message_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      dropdownColor: AppColors.cardHigh,
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('General')),
                        DropdownMenuItem(value: 'payment', child: Text('Payment')),
                        DropdownMenuItem(value: 'job', child: Text('Job Issue')),
                        DropdownMenuItem(value: 'kyc', child: Text('KYC / Verification')),
                      ],
                      onChanged: (value) => setState(() => _category = value ?? 'general'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      dropdownColor: AppColors.cardHigh,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                      ],
                      onChanged: (value) => setState(() => _priority = value ?? 'medium'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send Support Request'),
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel('My Tickets'),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2)),
                )
              else if (_tickets.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('No support tickets yet.', style: TextStyle(color: AppColors.grey)),
                )
              else
                ..._tickets.map((ticket) {
                  final item = ticket as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['subject'] as String? ?? 'Support',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              item['status'] as String? ?? 'open',
                              style: const TextStyle(color: AppColors.green, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'] as String? ?? '',
                          style: const TextStyle(color: AppColors.greyLight, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  );
                }),
            const SizedBox(height: 12),
            _contactCard(
              Icons.email_rounded,
              'Email Support',
              'support@fixngo.in • Usually within 24 hours',
              AppColors.red,
              () {},
              fullWidth: true,
            ),
            const SizedBox(height: 28),
            const SectionLabel('FAQs'),
            ...List.generate(_faqs.length, (i) {
              final open = _openFaq == i;
              return GestureDetector(
                onTap: () => setState(() => _openFaq = open ? null : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: open ? AppColors.cardHigh : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: open ? AppColors.red.withValues(alpha: 0.3) : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _faqs[i]['q']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            open ? Icons.remove_rounded : Icons.add_rounded,
                            color: open ? AppColors.red : AppColors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                      if (open) ...[
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 10),
                        Text(
                          _faqs[i]['a']!,
                          style: const TextStyle(
                            color: AppColors.greyLight,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
    IconData icon,
    String title,
    String sub,
    Color color,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(color: AppColors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportHelp(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: AppColors.greyLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
