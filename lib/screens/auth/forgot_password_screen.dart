import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/info_banner.dart';

/// Forgot Password screen — request a reset link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.requestPasswordReset(_identifierController.text.trim());
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reset link sent! Check your email or SMS.')),
      );
      Navigator.of(context).pushNamed(AppRoutes.resetPassword);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Request failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: SvgPicture.asset(AppConstants.logoSvg, height: 34),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "No worries! Enter your email or phone number associated with your Tatum account and we'll send you a reset link.",
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomInput(
                        label: 'Email or Phone Number',
                        hint: 'Enter your email or phone number',
                        icon: Icons.person_outline,
                        controller: _identifierController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: Validators.identifier,
                      ),
                      const InfoBanner(
                        icon: Icons.visibility_off_outlined,
                        title: 'Secure & Private',
                        message:
                            "We'll send you a secure link to reset your password.",
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'Send Reset Link',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.cream,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.lock_outline,
                        color: AppColors.yellowDark),
                  ),
                  const SizedBox(height: 12),
                  const Text('Need help?',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
