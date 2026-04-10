import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'integration_runtime_stub.dart'
    if (dart.library.io) 'integration_runtime_io.dart' as platform_impl;

const String _prefsKey = 'api_base_url_override';

/// Адрес API. Приоритет:
/// 1. `--dart-define=INTEGRATION_BASE_URL=...`
/// 2. Сохранённый в приложении URL (экран входа → «Адрес сервера»)
/// 3. Платформенное умолчание (эмулятор `10.0.2.2`, и т.д.)
///
/// Для **телефона и VPS** без `dart-define` обязательно укажите URL, например:
/// `http://72.56.244.26:8080`
class IntegrationRuntime {
  IntegrationRuntime._();

  static String? _prefsOverride;

  static String _stripTrailingSlash(String u) => u.replaceAll(RegExp(r'/$'), '');

  /// Вызвать из `main()` до `runApp`.
  static Future<void> loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_prefsKey)?.trim();
    _prefsOverride = (v == null || v.isEmpty) ? null : _stripTrailingSlash(v);
  }

  /// Сохранить и применить базовый URL (без `/` в конце).
  static Future<void> saveServerUrlOverride(String? url) async {
    final p = await SharedPreferences.getInstance();
    final t = url?.trim() ?? '';
    if (t.isEmpty) {
      _prefsOverride = null;
      await p.remove(_prefsKey);
      return;
    }
    final normalized = _stripTrailingSlash(t);
    _prefsOverride = normalized;
    await p.setString(_prefsKey, normalized);
  }

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('INTEGRATION_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return _stripTrailingSlash(fromEnv);
    }
    if (_prefsOverride != null && _prefsOverride!.isNotEmpty) {
      return _prefsOverride!;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8080';
    }
    return platform_impl.integrationPlatformDefaultBase;
  }
}
