import 'package:flutter/material.dart';

import '../app/theme.dart';

/// The light-lavender information banner used across the auth screens
/// ("Didn't receive the code?", "Secure & Private", KYC prompt).
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String message;
  final Widget? action;

  const InfoBanner({
    super.key,
    this.icon = Icons.info_outline,
    this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBanner,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 8),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
