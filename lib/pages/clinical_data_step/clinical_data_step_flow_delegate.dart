import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/main.dart';

import 'package:http/http.dart' as http;

class ClinicalDataStepFlowDelegate extends ChangeNotifier
    implements FlowStepDelegate {
  ClinicalDataStepFlowDelegate({
    required this.backable,
    required this.flowData,
  });

  final FlowData flowData;
  final bool backable;
  final systolicController = TextEditingController();
  final diastolycController = TextEditingController();

  bool _isLoading = false;

  @override
  bool get canGoBack => backable;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<ApiResponse> onNext() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:3000/api/screening/${flowData.screeningId}/clinical',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "systolicBp": systolicController.text,
          "diastolicBp": diastolycController.text,
          "headache": true,
          "chestPain": false,
          "visualDisturbance": false,
          "frequentUrinationNight": false,
          "shortnessOfBreath": false,
          "polyphagia": false,
          "dizziness": false,
          "polydipsia": false,
        }),
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
}
