import 'package:flutter/material.dart';
import 'book_appointment.dart';
import 'doctor_status.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/backend_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showOfflineAlert = false;

  @override
  void initState() {
    super.initState();
    // subscribe to doctor status via provider? We'll do that in DoctorStatus screen.
  }

  void _toggleTheme() {
    Provider.of<ThemeNotifier>(context, listen: false).toggleMode();
  }

  void _logAction(String action) {
    Provider.of<BackendService>(context, listen: false)
        .logAction({'action': action, 'timestamp': DateTime.now().toIso8601String()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TeleKiosk Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _toggleTheme, icon: Icon(Icons.brightness_6)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () {
                _logAction('navigate_book_appointment');
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookAppointmentPage()));
              },
              child: Text('Book Appointment'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _logAction('navigate_doctor_status');
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => DoctorStatusPage()));
              },
              child: Text('Doctor Status'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 56)),
            ),
            SizedBox(height: 36),
            Text('Kiosk mode enabled. App launches on boot.'),
          ]),
        ),
      ),
    );
  }
}

