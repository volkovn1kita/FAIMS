import 'package:faims/data/dtos/analytics_dtos.dart';
import 'package:faims/data/services/analytics_api_service.dart';

class AnalyticsRepository {
  final AnalyticsApiService _apiService = AnalyticsApiService();

  Future<DashboardStatsDto> getGlobalStats() async {
    try {
      return await _apiService.getGlobalStats();
    } catch (e) {
      rethrow;
    }
  }
}