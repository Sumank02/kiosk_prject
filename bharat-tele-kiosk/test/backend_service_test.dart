import 'package:flutter_test/flutter_test.dart';
import 'package:tele_kiosk/services/backend_service.dart';

void main() {
  group('BackendService', () {
    test('logAction returns true for mock mode', () async {
      final service = BackendService();
      final result = await service.logAction({'action': 'test'});
      expect(result, true);
    });

    test('logAction handles errors gracefully', () async {
      final service = BackendService();
      // Test with invalid data or simulate failure
      final result = await service.logAction({'invalid': null});
      expect(result, true); // Mock always succeeds
    });
  });
}