import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/account/account_info_screen.dart';
import '../screens/account/account_limits_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/common/not_found_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Named routes with a simple route guard
/// (Week 3, Session 7 + Week 5, Session 15).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String accountInfo = '/account-info';
  static const String accountLimits = '/account-limits';

  /// Screens that require a logged-in user.
  static const Set<String> _protected = {home, accountInfo, accountLimits};

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? splash;

    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        // Guard: one-shot read, no subscription needed at route time.
        if (_protected.contains(name)) {
          final loggedIn = context.read<AuthProvider>().isLoggedIn;
          if (!loggedIn) return const LoginScreen();
        }

        return switch (name) {
          splash         => const SplashScreen(),
          welcome        => const WelcomeScreen(),
          register       => const RegisterScreen(),
          otp            => const OtpScreen(),
          login          => const LoginScreen(),
          forgotPassword => const ForgotPasswordScreen(),
          resetPassword  => const ResetPasswordScreen(),
          home           => const HomeScreen(),
          accountInfo    => const AccountInfoScreen(),
          accountLimits  => const AccountLimitsScreen(),
          _              => const NotFoundScreen(),
        };
      },
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => const NotFoundScreen());
}