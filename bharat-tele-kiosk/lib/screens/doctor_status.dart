import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../services/backend_service.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorStatusPage extends StatefulWidget {
  @override
  State<DoctorStatusPage> createState() => _DoctorStatusPageState();
}

class _DoctorStatusPageState extends State<DoctorStatusPage> {
  late WebSocketService ws;
  StreamSubscription? _sub;
  bool _online = false;
  String _lastMsg = '';
  StreamSubscription<DatabaseEvent>? _fbSub;
  // Single-speciality doctor items rendered in the list
  List<_DoctorItem> _doctors = [];
  final String _dbUrl = 'https://tele-kiosk-default-rtdb.firebaseio.com/';

  @override
  void initState() {
    super.initState();
    ws = Provider.of<WebSocketService>(context, listen: false);
    ws.enabled = false; // use Firebase as the single source of truth (static)
    _sub = ws.stream.listen((msg) {
      setState(() {
        _lastMsg = msg;
        final lc = msg.toLowerCase();
        if (lc.contains('online')) {
          _online = true;
        } else if (lc.contains('offline')) {
          _online = false;
          _alertOffline();
        }
      });
      // log status update
      Provider.of<BackendService>(context, listen: false).logAction({'action': 'doctor_status_update', 'message': msg});
    }, onError: (e) {
      setState(() => _lastMsg = 'Error: $e');
    });

    // Also listen from Firebase Realtime Database: aggregate online status
    final db = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _dbUrl);
    final doctorsRef = db.ref('doctors');
    _fbSub = doctorsRef.onValue.listen((event) {
      final raw = event.snapshot.value;
      if (raw == null) {
        setState(() {
          _doctors = [];
          _online = false;
          _lastMsg = 'firebase_update: empty';
        });
        return;
      }
      final Map<dynamic, dynamic> data = (raw is Map
          ? raw
          : (raw is List ? raw.asMap() : <dynamic, dynamic>{})) as Map<dynamic, dynamic>;
      bool anyOnline = false;
      final List<_DoctorItem> doctors = [];
      data.forEach((key, v) {
        final map = (v as Map?) ?? {};
        final name = (map["name"]?.toString() ?? key.toString());
        final status = (map["status"]?.toString().toLowerCase() ?? 'offline');
        final speciality = (map["speciality"]?.toString() ?? 'General');
        doctors.add(_DoctorItem(name: name, speciality: speciality, status: status));
        if (status == 'online') anyOnline = true;
      });
      setState(() {
        _online = anyOnline;
        _doctors = doctors;
        _lastMsg = 'firebase_update';
      });
      if (!anyOnline) _alertOffline();
      Provider.of<BackendService>(context, listen: false).logAction({'action': 'doctor_status_update_fb', 'anyOnline': anyOnline, 'count': doctors.length});
    });
  }

  Future<void> _seedSample() async {
    try {
      final db = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _dbUrl);
      final doctorsRef = db.ref('doctors');
      // Clear and push children to avoid invalid key characters
      await doctorsRef.set(null);
      final seed = [
        {'name': 'Dr Alice', 'status': 'online'},
        {'name': 'Dr Bob', 'status': 'offline'},
        {'name': 'Dr Carol', 'status': 'online'},
      ];
      for (final item in seed) {
        await doctorsRef.push().set(item);
      }
      setState(() => _lastMsg = 'seeded sample');
    } catch (e) {
      setState(() => _lastMsg = 'seed failed: $e');
    }
  }

  void _alertOffline() {
    // UI alert when doctor goes offline
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text('Doctor Offline'),
        content: Text('The doctor has gone offline. Please try again later.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _fbSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Status'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 8),
          Text('Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Expanded(
            child: _doctors.isEmpty
                ? Center(child: Text('No doctors found'))
                : ListView.separated(
                    itemCount: _doctors.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = _doctors[i];
                      final isOnline = item.status.toLowerCase() == 'online';
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.speciality),
                        trailing: Chip(
                          label: Text(isOnline ? 'Online' : 'Offline'),
                          backgroundColor: isOnline ? Colors.green[100] : Colors.red[100],
                          labelStyle: TextStyle(color: isOnline ? Colors.green[900] : Colors.red[900]),
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}

class _DoctorItem {
  final String name;
  final String speciality;
  final String status;
  _DoctorItem({required this.name, required this.speciality, required this.status});
}
