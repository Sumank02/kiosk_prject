import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class BookAppointmentPage extends StatefulWidget {
  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _name = TextEditingController();
  DateTime? _selectedDate;
  String _status = '';

  // Online doctors fetched from Firebase
  final String _dbUrl = 'https://tele-kiosk-default-rtdb.firebaseio.com/';
  StreamSubscription<DatabaseEvent>? _sub;
  List<Map<String, String>> _onlineDoctors = [];
  Map<String, String>? _selectedDoctor; // {name, speciality}

  @override
  void initState() {
    super.initState();
    // Listen to doctors and filter online
    final db = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _dbUrl);
    final doctorsRef = db.ref('doctors');
    _sub = doctorsRef.onValue.listen((event) {
      final raw = event.snapshot.value;
      final List<Map<String, String>> found = [];
      if (raw is Map) {
        raw.forEach((_, v) {
          final map = (v as Map?) ?? {};
          final status = (map['status']?.toString().toLowerCase() ?? 'offline');
          if (status == 'online') {
            found.add({
              'name': map['name']?.toString() ?? 'Doctor',
              'speciality': map['speciality']?.toString() ?? 'General',
            });
          }
        });
      }
      setState(() {
        _onlineDoctors = found;
        // Clear selection if not in new list
        if (_selectedDoctor != null && !_onlineDoctors.any((d) => d['name'] == _selectedDoctor!['name'])) {
          _selectedDoctor = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _name.dispose();
    super.dispose();
  }

  void _book() async {
    if (_name.text.trim().isEmpty || _selectedDate == null || _selectedDoctor == null) {
      setState(() => _status = 'Enter name, date, and select an online doctor');
      return;
    }
    final payload = {
      'name': _name.text.trim(),
      'date': _selectedDate!.toIso8601String(),
      'doctor': _selectedDoctor!['name'],
      'speciality': _selectedDoctor!['speciality'],
      'timestamp': DateTime.now().toIso8601String(),
    };
    setState(() => _status = 'Booking...');
    final resp = await Provider.of<BackendService>(context, listen: false).logAction({'action': 'book', 'payload': payload});
    setState(() => _status = resp ? 'Booked successfully' : 'Booking failed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: InputDecoration(labelText: 'Patient name')),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(_selectedDate == null ? 'No date selected' : _selectedDate!.toLocal().toString().split(' ')[0])),
              TextButton(
                child: Text('Pick Date'),
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 365)));
                  if (d != null) setState(() => _selectedDate = d);
                },
              )
            ],
          ),
          SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: Text('Select Online Doctor')),
          DropdownButton<Map<String, String>>(
            isExpanded: true,
            value: _selectedDoctor,
            hint: Text(_onlineDoctors.isEmpty ? 'No online doctors' : 'Choose doctor'),
            items: _onlineDoctors.map((d) {
              final label = '${d['name']} — ${d['speciality']}';
              return DropdownMenuItem<Map<String, String>>(
                value: d,
                child: Text(label),
              );
            }).toList(),
            onChanged: _onlineDoctors.isEmpty ? null : (v) => setState(() => _selectedDoctor = v),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _book, child: Text('Confirm')),
          SizedBox(height: 12),
          Text(_status),
        ]),
      ),
    );
  }
}
