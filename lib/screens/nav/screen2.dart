import 'package:flutter/material.dart';
import 'package:tatum_bank/screens/nav/screen3.dart';
class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel X')),
            Center(
              child: GestureDetector(
                onTap: (){
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => const Screen3()));
                },
                  child: Text('Tap to go to screen 3')),
            ),
          ],
        ),
      )
    );
  }
}
