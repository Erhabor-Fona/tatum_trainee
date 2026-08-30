import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/account_limit.dart';
import '../../providers/account_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/loading_widget.dart';

/// Account Limits / KYC screen — segmented tabs, transaction limits,
/// KYC prompt, and quick actions.
class AccountLimitsScreen extends StatefulWidget {
  const AccountLimitsScreen({super.key});

  @override
  State<AccountLimitsScreen> createState() => _AccountLimitsScreenState();
}

class _AccountLimitsScreenState extends State<AccountLimitsScreen> {
  int _tab = 0; // 0 = Account Limits, 1 = KYC Status

  static const List<IconData> _limitIcons = [
    Icons.swap_horiz,
    Icons.account_balance_outlined,
    Icons.receipt_long_outlined,
    Icons.smartphone_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>();
    final limits = accounts.limits;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Account Limits / KYC'),
      ),
      body: limits.isEmpty
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _SegmentedTabs(
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 24),
                if (_tab == 0) ..._buildLimitsTab(limits) else
                  ..._buildKycTab(),
              ],
            ),
    );
  }

  List<Widget> _buildLimitsTab(List<AccountLimit> limits) {
    return [
      const Text('Transaction Limits',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text(
        'Your transaction limits determine how much you can transact daily across different channels.',
        style: TextStyle(
            fontSize: 13.5, height: 1.45, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 18),
      ...List.generate(limits.length, (i) {
        final limit = limits[i];
        return _LimitTile(
          icon: _limitIcons[i % _limitIcons.length],
          limit: limit,
        );
      }),
      const SizedBox(height: 10),
      InfoBanner(
        title: 'Need to increase your limits?',
        message: 'Upgrade your account by completing KYC verification.',
        action: GestureDetector(
          onTap: () => setState(() => _tab = 1),
          child: const Text(
            'Go to KYC Status',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              decoration: TextDecoration.underline,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      const Text('Quick Actions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      const _QuickActionTile(
        icon: Icons.tune,
        title: 'Manage Limits',
        subtitle: 'Request to increase your limits',
      ),
      const _QuickActionTile(
        icon: Icons.menu_book_outlined,
        title: 'Transaction Limits Guide',
        subtitle: 'Learn more about account limits',
      ),
    ];
  }

  List<Widget> _buildKycTab() {
    return [
      const Text('KYC Status',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      const _KycTile(
          title: 'BVN Verification', status: 'Completed', done: true),
      const _KycTile(
          title: 'Valid ID Document', status: 'Completed', done: true),
      const _KycTile(
          title: 'Proof of Address', status: 'Pending', done: false),
      const SizedBox(height: 12),
      const InfoBanner(
        message:
            'Complete all KYC steps to unlock higher transaction limits on your account.',
      ),
    ];
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int i) {
      final selected = index == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.navy : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          tab('Account Limits', 0),
          tab('KYC Status', 1),
        ],
      ),
    );
  }
}

class _LimitTile extends StatelessWidget {
  final IconData icon;
  final AccountLimit limit;
  const _LimitTile({required this.icon, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111A2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.infoBanner,
            child: Icon(icon, size: 20, color: AppColors.navy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(limit.title,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(limit.subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.naira(limit.limit),
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              if (limit.used != null) ...[
                const SizedBox(height: 3),
                Text(
                  'Used: ${Helpers.naira(limit.used!)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.success),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111A2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.infoBanner,
            child: Icon(icon, size: 20, color: AppColors.navy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _KycTile extends StatelessWidget {
  final String title;
  final String status;
  final bool done;

  const _KycTile(
      {required this.title, required this.status, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111A2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: done
                ? AppColors.success.withOpacity(0.12)
                : AppColors.infoBanner,
            child: Icon(
              done ? Icons.check : Icons.hourglass_bottom,
              size: 20,
              color: done ? AppColors.success : AppColors.navy,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w700)),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: done ? AppColors.success : AppColors.yellowDark,
            ),
          ),
        ],
      ),
    );
  }
}
