import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

/// Account Information screen — dark account card, personal information,
/// account details, and statement download.
class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>();
    final user = context.watch<AuthProvider>().user;
    final account = accounts.account;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Account Information'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'limits') {
                Navigator.of(context).pushNamed(AppRoutes.accountLimits);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'limits', child: Text('Account Limits / KYC')),
            ],
          ),
        ],
      ),
      body: account == null || user == null
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _AccountCard(
                  accountType: account.accountType,
                  accountNumber: account.accountNumber,
                  balance: accounts.balanceHidden
                      ? '\u20A6 \u2022\u2022\u2022\u2022\u2022\u2022'
                      : Helpers.naira(account.availableBalance),
                  onToggle: accounts.toggleBalanceVisibility,
                  hidden: accounts.balanceHidden,
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Personal Information'),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'FULL NAME',
                  value: user.fullName,
                ),
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'DATE OF BIRTH',
                  value: user.dateOfBirth,
                ),
                _InfoTile(
                  icon: Icons.mail_outline,
                  label: 'EMAIL ADDRESS',
                  value: user.email,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'PHONE NUMBER',
                  value: user.phone,
                ),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'RESIDENTIAL ADDRESS',
                  value: user.address,
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Account Information'),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF111A2E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _KeyValueRow('Account Type', account.accountType),
                      _KeyValueRow('BVN', account.bvnMasked),
                      _KeyValueRow('Currency', account.currency),
                      _KeyValueRow('Date Opened', account.dateOpened),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Account Status',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              account.status,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Your account statement is on its way.')),
                    );
                  },
                  icon: const Icon(Icons.download_outlined, size: 20),
                  label: const Text('Download Account Statement'),
                ),
              ],
            ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String accountType;
  final String accountNumber;
  final String balance;
  final bool hidden;
  final VoidCallback onToggle;

  const _AccountCard({
    required this.accountType,
    required this.accountNumber,
    required this.balance,
    required this.hidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              accountType,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACCOUNT NUMBER',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 10.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          accountNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.copy,
                            size: 14, color: Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'AVAILABLE BALANCE',
                    style: TextStyle(
                      color: AppColors.yellow,
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        balance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style:
              const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.infoBanner,
            child: Icon(icon, size: 19, color: AppColors.navy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600)),
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

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValueRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
