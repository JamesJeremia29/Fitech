import 'package:fitech_mobile_apps/login.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetologin();
  }

  _navigatetologin() async {
    await Future.delayed(Duration(milliseconds: 1500),
        () {}); //delay 1.5 seconds before navigation
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  } //Push Navigation function to Login Screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
            child:
                Image.asset('assets/image/launch_logo.png')), // add image asset
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey, Colors.black87])), //gradient background
      ),
    );
  }
}
