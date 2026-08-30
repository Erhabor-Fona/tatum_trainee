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

/// Login Screen (M03) — Welcome Back.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login failed.')),
      );
    }
  }

  void _biometrics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Biometric login is coming soon to Tatum Bank.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child:
                      SvgPicture.asset(AppConstants.logoSvg, height: 48),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Log in to your Tatum account',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                CustomInput(
                  label: 'Email or Phone Number',
                  hint: 'john.doe@email.com',
                  icon: Icons.person_outline,
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.identifier,
                ),
                CustomInput(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      Validators.requiredField(v, 'Password'),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Remember me',
                        style: TextStyle(fontSize: 14.5)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.forgotPassword),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Log In',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          letterSpacing: 2,
                          color: AppColors.textSecondary.withOpacity(0.9),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _biometrics,
                  icon: const Icon(Icons.fingerprint, size: 24),
                  label: const Text('Log in with Biometrics'),
                ),
                const SizedBox(height: 28),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.register),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(text: "Don't have an account?  "),
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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
