import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tatum_bank/welcome_screen.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  @override
  void initState() {
    super.initState();
    _navigateAfterThreeSeconds(context);
  }

  Future<void> _navigateAfterThreeSeconds(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                Center(
                  child: SvgPicture.asset(
                    'assets/svg/logotatum.svg',
                    width: 70,
                    height: 70,
                  ),
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Banking that\nkeeps you smiling',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'All-in-one Banking. All for you',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(
                'assets/svg/yellowvector.svg',
                width: double.infinity,
                height: 280, // add this
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
