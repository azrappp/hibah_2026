import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/main.dart';

import 'package:http/http.dart' as http;

class BloodSugarStepFlowDelegate extends ChangeNotifier
    implements FlowStepDelegate {
  BloodSugarStepFlowDelegate({required this.backable, required this.flowData});

  final FlowData flowData;
  final bool backable;

  final glucoseValueController = TextEditingController();

  String glucoseTestType = 'TWO_HOUR';
  bool hasClassicSymptoms = false;

  bool _isLoading = false;

  @override
  bool get canGoBack => backable;

  @override
  bool get isLoading => _isLoading;

  void setGlucoseTestType(String value) {
    glucoseTestType = value;

    if (glucoseTestType != 'RANDOM') {
      hasClassicSymptoms = false;
    }

    notifyListeners();
  }

  void setHasClassicSymptoms(bool value) {
    hasClassicSymptoms = value;
    notifyListeners();
  }

  String get valueSuffix {
    if (glucoseTestType == 'HBA1C') {
      return '%';
    }

    return 'mg/dL';
  }

  String get valueHint {
    switch (glucoseTestType) {
      case 'FPG':
        return 'Contoh: 88';
      case 'TWO_HOUR':
        return 'Contoh: 120';
      case 'RANDOM':
        return 'Contoh: 110';
      case 'HBA1C':
        return 'Contoh: 5.2';
      default:
        return 'Contoh: 110';
    }
  }

  String get valueLabel {
    switch (glucoseTestType) {
      case 'FPG':
        return 'FPG';
      case 'TWO_HOUR':
        return '2-h PG';
      case 'RANDOM':
        return 'Random PG';
      case 'HBA1C':
        return 'HbA1c';
      default:
        return 'Nilai gula darah';
    }
  }

  String get valueHelper {
    switch (glucoseTestType) {
      case 'FPG':
        return 'Masukkan hasil gula darah puasa';
      case 'TWO_HOUR':
        return 'Masukkan hasil gula darah 2 jam setelah makan';
      case 'RANDOM':
        return 'Masukkan hasil gula darah sewaktu';
      case 'HBA1C':
        return 'Masukkan hasil HbA1c';
      default:
        return 'Masukkan nilai pemeriksaan';
    }
  }

  @override
  Future<ApiResponse> onNext() async {
    try {
      final glucoseValue = double.tryParse(glucoseValueController.text.trim());

      if (glucoseValue == null || glucoseValue <= 0) {
        debugPrint('Invalid glucose value');
        return ApiResponse(success: false);
      }

      _isLoading = true;
      notifyListeners();

      final body = <String, dynamic>{
        "glucoseTestType": glucoseTestType,
        "glucoseValue": glucoseValue,
      };

      if (glucoseTestType == 'RANDOM') {
        body["hasClassicSymptoms"] = hasClassicSymptoms;
      }

      final response = await http.post(
        AppConfig.apiUri('/api/screening/${flowData.screeningId}/biochemical'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        debugPrint(response.body);
        final mapResponse = jsonDecode(response.body);
        return ApiResponse(success: true, data: mapResponse);
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

  @override
  void dispose() {
    glucoseValueController.dispose();
    super.dispose();
  }
}
