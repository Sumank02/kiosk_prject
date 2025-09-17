import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/splash.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'services/websocket_service.dart';
import 'services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kRealtimeDbUrl = 'https://tele-kiosk-default-rtdb.firebaseio.com/';

Future<void> _seedDoctorsOnce() async {
  final db = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: kRealtimeDbUrl);
  final DatabaseReference doctorsRef = db.ref("doctors");
  // Reset and push items to avoid invalid key characters in names
  await doctorsRef.set(null);
  final List<Map<String, String>> seed = [
    {"name": "Dr Alice", "status": "online", "speciality": "Orthopedic"},
    {"name": "Dr Bob", "status": "offline", "speciality": "Gynecologist"},
    {"name": "Dr Carol", "status": "online", "speciality": "Cardiologist"},
  ];
  for (final item in seed) {
    await doctorsRef.push().set(item);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool dark = prefs.getBool('darkTheme') ?? false;

  // Seed doctors once (idempotent in this demo; will overwrite the node)
  try { await _seedDoctorsOnce(); } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(dark ? ThemeMode.dark : ThemeMode.light)),
        Provider(create: (_) => WebSocketService()),
        Provider(create: (_) => BackendService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Auto-lock inactivity timer (2 minutes)
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(minutes: 2), () {
      // On inactivity -> logout (go back to login)
      Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()), (r) => false);
    });
  }

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return GestureDetector(
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'TeleKiosk',
        themeMode: themeNotifier.themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: SplashScreen(
          next: LoginPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
