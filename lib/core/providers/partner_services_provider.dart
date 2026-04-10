import 'package:flutter/foundation.dart';

import '../../data/models/partner_service_item.dart';
import '../../data/repositories/partner_services_repository.dart';

class PartnerServicesProvider with ChangeNotifier {
  final PartnerServicesRepository _repository = PartnerServicesRepository();
  List<PartnerServiceItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<PartnerServiceItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    await Future<void>.delayed(Duration.zero);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.fetchServices();
    } catch (e) {
      _error = 'Ошибка загрузки услуг: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerScan(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    await _repository.scanQrPayload(trimmed);
    await loadServices();
  }
}
