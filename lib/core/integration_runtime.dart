import 'package:flutter/foundation.dart' show kIsWeb;

import 'integration_runtime_stub.dart'
    if (dart.library.io) 'integration_runtime_io.dart' as platform_impl;

/// Адрес API: приоритет — `--dart-define=INTEGRATION_BASE_URL=...`.
///
/// Если не задан:
/// - **Android** (эмулятор): `http://10.0.2.2:8080`.
/// - Остальное (в т.ч. web): `http://127.0.0.1:8080`.
///
/// **Физическое устройство в Wi‑Fi:** `flutter run --dart-define=INTEGRATION_BASE_URL=http://IP_ПК:8080`
class IntegrationRuntime {
  IntegrationRuntime._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('INTEGRATION_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/$'), '');
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8080';
    }
    return platform_impl.integrationPlatformDefaultBase;
  }
}
