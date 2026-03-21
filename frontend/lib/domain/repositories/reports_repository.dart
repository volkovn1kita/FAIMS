import 'package:frontend/data/dtos/report_item_dto.dart';
import 'package:frontend/data/services/reports_api_service.dart';

class ReportsRepository {
  final ReportsApiService _apiService = ReportsApiService();

  Future<List<ReportItemDto>> getPurchasingReport(DateTime startDate, DateTime endDate) async {
    return await _apiService.getPurchasingReport(startDate, endDate);
  }

  Future<List<ReportItemDto>> getDisposalReport(DateTime startDate, DateTime endDate) async {
    return await _apiService.getDisposalReport(startDate, endDate);
  }
}