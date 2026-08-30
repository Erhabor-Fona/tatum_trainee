import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/otp_input.dart';

/// Enter OTP screen — Verify Your Identity with a resend countdown.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  int _secondsLeft = AppConstants.otpResendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = AppConstants.otpResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.length != AppConstants.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code to continue.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(_code);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Verification failed.')),
      );
    }
  }

  void _resend() {
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A new code has been sent to your phone.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final phone = auth.pendingPhoneMasked.isEmpty
        ? '+234 **** 1234'
        : auth.pendingPhoneMasked;
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the 6-digit code sent to your phone number $phone',
                style: const TextStyle(
                  fontSize: 15.5,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              OtpInput(
                onChanged: (code) => _code = code,
                onCompleted: (code) => _code = code,
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Resend code in $mm:$ss',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: _secondsLeft == 0 ? _resend : null,
                      child: const Text('Resend'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Log In',
                isLoading: auth.isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: 24),
              const InfoBanner(
                message:
                    "Didn't receive the code? Check your spam folder or try again.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
