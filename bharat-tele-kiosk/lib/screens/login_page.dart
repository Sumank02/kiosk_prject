import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final hardUser = 'kioskuser';
  final hardPass = 'kiosk@123';

  String? _error;

  void _tryLogin() {
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text.trim();
    if (u == hardUser && p == hardPass) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      setState(() => _error = 'Invalid credentials');
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No back button on login (kiosk)
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.medical_services, size: 80),
              SizedBox(height: 12),
              Text('Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              TextField(controller: _userCtrl, decoration: InputDecoration(labelText: 'Username')),
              SizedBox(height: 8),
              TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 12),
              if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 12),
              ElevatedButton(onPressed: _tryLogin, child: Text('Login')),
            ]),
          ),
        ),
      ),
    );
  }
}
