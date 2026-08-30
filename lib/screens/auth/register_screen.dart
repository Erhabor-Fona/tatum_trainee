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

/// Register Screen — Create Account form with validation and T&C consent.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please agree to the Terms and Conditions to continue.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamed(AppRoutes.otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registration failed.')),
      );
    }
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join Tatum Bank today',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                CustomInput(
                  label: 'Full Name',
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: Validators.fullName,
                ),
                CustomInput(
                  label: 'Email Address',
                  hint: 'john.doe@email.com',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                CustomInput(
                  label: 'Phone Number',
                  hint: '+1 234 567 890',
                  icon: Icons.smartphone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                CustomInput(
                  label: 'Password',
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Log In',
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
