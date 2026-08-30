import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatum_bank/screens/nav/screen1.dart';
import 'package:tatum_bank/screens/nav/screen3.dart';

import 'app/constants.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'providers/account_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const TatumBankApp());
}

/// Tatum Bank — Techware Academy Flutter capstone project.
class TatumBankApp extends StatelessWidget {
  const TatumBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          // theme: AppTheme.light,
          // darkTheme: AppTheme.dark,
          // themeMode: auth.darkMode ? ThemeMode.dark : ThemeMode.light,
          // initialRoute: AppRoutes.splash,
          // onGenerateRoute: AppRoutes.onGenerateRoute,
          // onUnknownRoute: AppRoutes.onUnknownRoute,
          home: Screen3(),
        ),
      ),
    );
  }
}
