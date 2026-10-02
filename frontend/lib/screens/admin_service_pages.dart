import 'package:flutter/material.dart';

class AdminServicePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<AdminServiceItem> items;

  const AdminServicePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 900 ? 32.0 : 18.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 145,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item.title} is ready for backend integration.',
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: item.iconColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item.icon, color: item.iconColor),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const AdminServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class AdminFinancePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminFinancePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Finance & Payments',
      subtitle: 'Manage university fees, payments and financial records.',
      icon: Icons.account_balance_wallet_outlined,
      items: [
        AdminServiceItem(
          title: 'Fee Management',
          subtitle: 'Configure tuition and university charges.',
          icon: Icons.receipt_long_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Payment Records',
          subtitle: 'Review student payment history.',
          icon: Icons.payments_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Outstanding Fees',
          subtitle: 'Track unpaid balances and deadlines.',
          icon: Icons.warning_amber_outlined,
          iconColor: Colors.orange,
        ),
        AdminServiceItem(
          title: 'Receipts',
          subtitle: 'Manage payment receipts and references.',
          icon: Icons.description_outlined,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}

class AdminHostelPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminHostelPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Hostel Management',
      subtitle: 'Manage accommodation, rooms, applications and occupancy.',
      icon: Icons.apartment_outlined,
      items: [
        AdminServiceItem(
          title: 'Hostel Applications',
          subtitle: 'Review and process student applications.',
          icon: Icons.assignment_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Rooms & Beds',
          subtitle: 'Manage rooms, beds and availability.',
          icon: Icons.bed_outlined,
          iconColor: Colors.blue,
        ),
        AdminServiceItem(
          title: 'Allocations',
          subtitle: 'Assign students to accommodation.',
          icon: Icons.meeting_room_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Maintenance',
          subtitle: 'Review hostel maintenance requests.',
          icon: Icons.build_outlined,
          iconColor: Colors.orange,
        ),
      ],
    );
  }
}

class AdminVisaPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminVisaPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Visa & Student Pass',
      subtitle: 'Monitor international student documents and renewals.',
      icon: Icons.badge_outlined,
      items: [
        AdminServiceItem(
          title: 'Visa Records',
          subtitle: 'View student pass and visa information.',
          icon: Icons.card_membership_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Expiring Documents',
          subtitle: 'Identify documents approaching expiry.',
          icon: Icons.event_outlined,
          iconColor: Colors.orange,
        ),
        AdminServiceItem(
          title: 'Renewal Applications',
          subtitle: 'Review renewal requests and statuses.',
          icon: Icons.autorenew_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Required Documents',
          subtitle: 'Manage visa renewal requirements.',
          icon: Icons.folder_outlined,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}

class AdminDocumentsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminDocumentsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Document Center',
      subtitle: 'Manage student documents and verification workflows.',
      icon: Icons.folder_copy_outlined,
      items: [
        AdminServiceItem(
          title: 'Student Documents',
          subtitle: 'Browse submitted student documents.',
          icon: Icons.folder_shared_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Verification',
          subtitle: 'Review and verify submitted documents.',
          icon: Icons.verified_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Official Letters',
          subtitle: 'Manage university letters and records.',
          icon: Icons.mail_outline,
          iconColor: Colors.blue,
        ),
        AdminServiceItem(
          title: 'Document History',
          subtitle: 'Track document submissions and updates.',
          icon: Icons.history,
          iconColor: Colors.orange,
        ),
      ],
    );
  }
}

class AdminAnnouncementsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminAnnouncementsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Announcements',
      subtitle: 'Publish important information to the university community.',
      icon: Icons.campaign_outlined,
      items: [
        AdminServiceItem(
          title: 'Create Announcement',
          subtitle: 'Publish a new university announcement.',
          icon: Icons.add_circle_outline,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Academic Notices',
          subtitle: 'Manage academic announcements.',
          icon: Icons.school_outlined,
          iconColor: Colors.blue,
        ),
        AdminServiceItem(
          title: 'Finance Notices',
          subtitle: 'Publish fee and payment information.',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Emergency Notices',
          subtitle: 'Manage urgent university communications.',
          icon: Icons.warning_amber_outlined,
          iconColor: Colors.red,
        ),
      ],
    );
  }
}

class AdminNotificationsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminNotificationsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Notifications',
      subtitle: 'Monitor system notifications and important alerts.',
      icon: Icons.notifications_none_outlined,
      items: [
        AdminServiceItem(
          title: 'System Alerts',
          subtitle: 'Monitor important system events.',
          icon: Icons.notifications_active_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Payment Alerts',
          subtitle: 'Track payment-related notifications.',
          icon: Icons.payment_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Visa Alerts',
          subtitle: 'Monitor visa and document expiry alerts.',
          icon: Icons.badge_outlined,
          iconColor: Colors.orange,
        ),
        AdminServiceItem(
          title: 'Announcement Delivery',
          subtitle: 'Monitor published notifications.',
          icon: Icons.send_outlined,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}

class AdminAiAssistantPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminAiAssistantPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'University AI Assistant',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        size: 44,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'University AI Assistant',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A central help assistant for university administration.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What the AI assistant will support',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16),
                            _AiFeature(
                              icon: Icons.help_outline,
                              text: 'University procedures and FAQs',
                            ),
                            _AiFeature(
                              icon: Icons.school_outlined,
                              text: 'Academic and enrollment guidance',
                            ),
                            _AiFeature(
                              icon: Icons.account_balance_wallet_outlined,
                              text: 'Finance and payment guidance',
                            ),
                            _AiFeature(
                              icon: Icons.apartment_outlined,
                              text: 'Hostel information',
                            ),
                            _AiFeature(
                              icon: Icons.badge_outlined,
                              text: 'Visa and student-pass guidance',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'AI responses will be connected to authorized university data during the AI integration phase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AiFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class AdminReportsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminReportsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Reports & Analytics',
      subtitle: 'University-wide reporting and administrative insights.',
      icon: Icons.analytics_outlined,
      items: [
        AdminServiceItem(
          title: 'Academic Reports',
          subtitle: 'Review academic performance and results.',
          icon: Icons.school_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'Enrollment Reports',
          subtitle: 'Analyze subject and student enrollment.',
          icon: Icons.how_to_reg_outlined,
          iconColor: Colors.blue,
        ),
        AdminServiceItem(
          title: 'Finance Reports',
          subtitle: 'Review payments and outstanding balances.',
          icon: Icons.bar_chart_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Hostel Reports',
          subtitle: 'Review accommodation occupancy.',
          icon: Icons.apartment_outlined,
          iconColor: Colors.orange,
        ),
      ],
    );
  }
}

class AdminSettingsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminSettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AdminServicePage(
      title: 'Administration Settings',
      subtitle: 'Configure system preferences and administration options.',
      icon: Icons.settings_outlined,
      items: [
        AdminServiceItem(
          title: 'University Profile',
          subtitle: 'Manage university information.',
          icon: Icons.account_balance_outlined,
          iconColor: Colors.indigo,
        ),
        AdminServiceItem(
          title: 'User Roles',
          subtitle: 'Review administrative access levels.',
          icon: Icons.admin_panel_settings_outlined,
          iconColor: Colors.blue,
        ),
        AdminServiceItem(
          title: 'System Preferences',
          subtitle: 'Configure application preferences.',
          icon: Icons.tune_outlined,
          iconColor: Colors.green,
        ),
        AdminServiceItem(
          title: 'Audit Activity',
          subtitle: 'Review important administrative actions.',
          icon: Icons.history_outlined,
          iconColor: Colors.orange,
        ),
      ],
    );
  }
}
