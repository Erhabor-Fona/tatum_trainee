import 'package:flutter/material.dart';
import 'package:tatum_bank/screens/nav/screen2.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext fona) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(fona);
                },
                child: const Text('Pop')),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      fona, MaterialPageRoute(builder: (fona) => const Screen2()));
            
                },
                child: const Text('Screen 1. tap to go to screen 2'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
