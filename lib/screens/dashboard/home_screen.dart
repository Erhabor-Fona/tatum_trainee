import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/bank_transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Home Dashboard (V2) — balance card, quick actions, invite banner,
/// recent transactions, and bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AccountProvider>().loadDashboard(),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content:
            const Text('You will need to log in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AccountProvider>().reset();
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  void _quickActionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: AppColors.navy),
              title: const Text('Transfer Money'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.navy),
              title: const Text('Pay Bills'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
            ListTile(
              leading:
                  const Icon(Icons.smartphone_outlined, color: AppColors.navy),
              title: const Text('Buy Airtime'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final accounts = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0B1220)
              : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: switch (accounts.state) {
          LoadState.loading || LoadState.idle =>
            const LoadingWidget(message: 'Loading your account...'),
          LoadState.error => EmptyState(
              icon: Icons.wifi_off_outlined,
              title: 'Something went wrong',
              message: accounts.errorMessage ??
                  'We could not load your account right now.',
              actionLabel: 'Try Again',
              onAction: () => accounts.loadDashboard(refresh: true),
            ),
          _ => RefreshIndicator(
              color: AppColors.yellowDark,
              onRefresh: () => accounts.loadDashboard(refresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _Header(
                    name: auth.user?.firstName ?? 'there',
                    onLogout: _confirmLogout,
                  ),
                  const SizedBox(height: 18),
                  _BalanceCard(onQuickActions: _quickActionsSheet),
                  const SizedBox(height: 26),
                  _SectionHeader(
                    title: 'Quick Actions',
                    onViewAll: _quickActionsSheet,
                  ),
                  const SizedBox(height: 14),
                  _QuickActionsRow(onMore: _quickActionsSheet),
                  const SizedBox(height: 26),
                  const Text(
                    'Get more out of Tatum',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  const _InviteBanner(),
                  const SizedBox(height: 26),
                  _SectionHeader(title: 'Recent Transactions', onViewAll: () {}),
                  const SizedBox(height: 8),
                  if (accounts.state == LoadState.empty)
                    const EmptyState(
                      title: 'No transactions yet',
                      message:
                          'Your recent transactions will show up here once you start banking.',
                    )
                  else
                    ...accounts.transactions
                        .map((t) => _TransactionTile(transaction: t)),
                ],
              ),
            ),
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Activity'),
          BottomNavigationBarItem(
              icon: Icon(Icons.headset_mic_outlined), label: 'Support'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none), label: 'Inbox'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  const _Header({required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.infoBanner,
          child: Icon(Icons.person, color: AppColors.navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name \u{1F44B}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const Text(
                'Welcome back! Check your status.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final VoidCallback onQuickActions;
  const _BalanceCard({required this.onQuickActions});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>();
    final account = accounts.account;
    if (account == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.accountType,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                        radius: 4, backgroundColor: AppColors.success),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ACCOUNT NUMBER',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.navy,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: account.accountNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Account number copied.')),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          account.accountNumber,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                accounts.balanceHidden
                    ? '\u20A6 \u2022\u2022\u2022\u2022\u2022\u2022'
                    : Helpers.naira(account.availableBalance),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: accounts.toggleBalanceVisibility,
                child: Icon(
                  accounts.balanceHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Available Balance',
              style: TextStyle(fontSize: 13.5, color: AppColors.navy)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.accountInfo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('View Account'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onQuickActions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.navy,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Quick Actions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onMore;
  const _QuickActionsRow({required this.onMore});

  @override
  Widget build(BuildContext context) {
    Widget action(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF111A2E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.navy),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        action(Icons.swap_horiz, 'Transfer\nMoney', () {}),
        action(Icons.receipt_long_outlined, 'Pay Bills', () {}),
        action(Icons.smartphone_outlined, 'Buy Airtime', () {}),
        action(Icons.grid_view_rounded, 'More', onMore),
      ],
    );
  }
}

class _InviteBanner extends StatelessWidget {
  const _InviteBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite your friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Invite your friends to download and save on Tatum app and start earning.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14),
          Icon(Icons.card_giftcard, color: AppColors.yellow, size: 42),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final BankTransaction transaction;
  const _TransactionTile({required this.transaction});

  IconData get _icon => switch (transaction.category) {
        'bills' => Icons.receipt_long_outlined,
        'credit' => Icons.arrow_downward,
        _ => Icons.arrow_upward,
      };

  @override
  Widget build(BuildContext context) {
    final credit = transaction.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111A2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: credit
                ? AppColors.success.withOpacity(0.12)
                : AppColors.infoBanner,
            child: Icon(_icon,
                size: 18,
                color: credit ? AppColors.success : AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  Helpers.transactionDate(transaction.date),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.signedNaira(transaction.amount, credit: credit),
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: credit ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(transaction.status,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
