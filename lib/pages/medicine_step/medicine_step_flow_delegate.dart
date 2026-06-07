import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/main.dart';

import 'package:http/http.dart' as http;

class MedicineStepFlowDelegate extends ChangeNotifier
    implements FlowStepDelegate {
  MedicineStepFlowDelegate({required this.backable, required this.flowData});

  final FlowData flowData;
  final bool backable;
  final hyDrugController = TextEditingController();
  final dmDrugController = TextEditingController();
  bool _isLoading = false;
  ApiResponse? apiResponse;
  @override
  bool get canGoBack => backable;

  @override
  bool get isLoading => _isLoading;

  bool get hasMedicine {
    return hyDrugController.text.trim().isNotEmpty ||
        dmDrugController.text.trim().isNotEmpty;
  }

  bool get shouldStopForInsulin {
    final medicationAssessment = apiResponse?.data?['data'];

    return medicationAssessment?['usesInsulin'] == true;
  }

  String get insulinAlertMessage {
    final medicationAssessment = apiResponse?.data?['data'];

    return medicationAssessment?['insulinAlertStatus']?.toString() ??
        'Silakan konsultasi lebih lanjut dengan dokter penyakit dalam dan ahli gizi.';
  }

  void clearMedicineFields() {
    hyDrugController.clear();
    dmDrugController.clear();
    notifyListeners();
  }

  @override
  Future<ApiResponse> onNext() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        AppConfig.apiUri('/api/screening/${flowData.screeningId}/medication'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "hypertensionDrugName": hyDrugController.text,
          "antidiabeticDrugName": dmDrugController.text,
        }),
      );
      if (response.statusCode == 201) {
        debugPrint(response.body);

        final mapResponse = jsonDecode(response.body);

        apiResponse = ApiResponse(success: true, data: mapResponse);

        return apiResponse!;
      }
      debugPrint('HTTP Error: ${response.statusCode} - ${response.body}');
      return ApiResponse(success: false);
    } catch (e) {
      debugPrint('Exception: $e');
      return ApiResponse(success: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
