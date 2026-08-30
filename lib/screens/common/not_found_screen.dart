import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../widgets/empty_state.dart';

/// Not-found screen for unknown routes (Week 3, Session 7).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: EmptyState(
        icon: Icons.search_off,
        title: "We can't find that page",
        message:
            'The screen you are looking for does not exist or has been moved.',
        actionLabel: 'Go Home',
        onAction: () => Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false),
      ),
    );
  }
}
