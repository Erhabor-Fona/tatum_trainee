import 'package:flutter/material.dart';
import 'package:tatum_bank/screens/nav/screen1.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateAfterThreeSeconds(context);
  }

  Future <void> _navigateAfterThreeSeconds (BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Screen1()));
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: (){
            //Navigator.popUntil(context , (route) => route.isFirst);

          },
            child: const Text('Splash Screen')),
      ),
    );
  }
}
