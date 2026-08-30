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

/// Reset Password screen — Create New Password with a live strength meter
/// and requirements checklist, exactly as designed in Figma.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _password = '';

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]]').hasMatch(_password);

  int get _strength =>
      [_hasMinLength, _hasUppercase, _hasNumber, _hasSpecial]
          .where((met) => met)
          .length;

  String get _strengthLabel => switch (_strength) {
        0 || 1 => 'Weak',
        2 => 'Fair',
        3 => 'Good',
        _ => 'Strong',
      };

  Color get _strengthColor => switch (_strength) {
        0 || 1 => AppColors.error,
        2 => Colors.orange,
        3 => AppColors.yellowDark,
        _ => AppColors.success,
      };

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(_passwordController.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Password reset successfully. Log in to continue.')),
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Reset failed.')),
      );
    }
  }

  Widget _requirement(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor:
                met ? AppColors.success : AppColors.border,
            child: const Icon(Icons.check, size: 13, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              color: met ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your new password below.',
                  style: TextStyle(
                    fontSize: 15.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 26),
                CustomInput(
                  label: 'New Password',
                  hint: 'Enter new password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.password,
                  onChanged: (v) => setState(() => _password = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password Strength',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _strengthLabel,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _strengthColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(4, (i) {
                    final active = i < _strength;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                        decoration: BoxDecoration(
                          color: active
                              ? _strengthColor
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                _requirement('At least 8 characters', _hasMinLength),
                _requirement('One uppercase letter', _hasUppercase),
                _requirement('One number', _hasNumber),
                _requirement('One special character', _hasSpecial),
                const SizedBox(height: 12),
                CustomInput(
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  icon: Icons.lock_outline,
                  controller: _confirmController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(
                      v, _passwordController.text),
                ),
                CustomButton(
                  label: 'Reset Password',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            AppRoutes.login, (route) => false),
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
    );
  }
}
