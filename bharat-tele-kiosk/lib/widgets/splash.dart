import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget next;
  SplashScreen({required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.next));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.medical_services, size: 96),
          SizedBox(height: 12),
          Text('TeleKiosk', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Kiosk Mode Telemedicine', style: TextStyle(fontSize: 14)),
        ]),
      ),
    );
  }
}
