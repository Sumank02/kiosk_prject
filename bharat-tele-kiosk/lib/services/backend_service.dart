import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BackendService {
  // If you have a real server, set this to its HTTPS endpoint. Leave `null` to keep logging local (mocked).
  // WARNING: ensure any real backend handles authentication and complies with privacy laws.
  final String? endpoint = null; // e.g.: 'https://api.yourdomain.com/log'

  Future<bool> logAction(Map<String, dynamic> payload) async {
    try {
      if (endpoint == null) {
        // Mock: simulate backend with delay
        await Future.delayed(Duration(milliseconds: 400));
        return true;
      } else {
        final resp = await http.post(Uri.parse(endpoint!), body: jsonEncode(payload), headers: {'Content-Type': 'application/json'});
        return resp.statusCode == 200;
      }
    } catch (e) {
      return false;
    }
  }
}

// Example function you can place in BackendService or a dedicated UpdateService.
Future<bool> downloadAndInstallApk(String apkUrl) async {
  try {
    final res = await http.get(Uri.parse(apkUrl));
    if (res.statusCode != 200) return false;
    final bytes = res.bodyBytes;
    final dir = await getExternalStorageDirectory();
    if (dir == null) return false;
    final file = File('${dir.path}/tele_kiosk_update.apk');
    await file.writeAsBytes(bytes);
    // Trigger install via platform channel or using intent (MainActivity.installApk)
    const platform = MethodChannel('tele_kiosk/update');
    await platform.invokeMethod('installApk', {'path': file.path});
    return true;
  } catch (e) {
    return false;
  }
}
