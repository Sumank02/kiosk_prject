import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BackendService {
  // replace with real endpoint if you have one
  final String? endpoint = null; // example: 'https://example.com/log'

  Future<bool> logAction(Map<String, dynamic> payload) async {
    try {
      if (endpoint == null) {
        // Mock: just print and simulate success
        print('Mock backend log: ${payload}');
        await Future.delayed(Duration(milliseconds: 400));
        return true;
      } else {
        final resp = await http.post(Uri.parse(endpoint!), body: jsonEncode(payload), headers: {'Content-Type': 'application/json'});
        return resp.statusCode == 200;
      }
    } catch (e) {
      print('Backend log failed: $e');
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
    print('update failed: $e');
    return false;
  }
}
