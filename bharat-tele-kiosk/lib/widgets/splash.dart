import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({required this.next, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.next));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
