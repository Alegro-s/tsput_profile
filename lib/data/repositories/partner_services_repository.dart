import '../../core/auth/secure_storage.dart';
import '../models/partner_service_item.dart';
import '../services/api_service.dart';

class PartnerServicesRepository {
  final ApiService _apiService = ApiService();

  Future<List<PartnerServiceItem>> fetchServices() async {
    final token = await SecureStorage.getAuthToken() ?? '';
    final raw = await _apiService.fetchPartnerServices(token);
    return raw
        .map((e) => PartnerServiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> scanQrPayload(String raw) async {
    final token = await SecureStorage.getAuthToken() ?? '';
    await _apiService.scanPartnerQr(token, raw);
  }
}
