import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
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
          'http://10.0.2.2:3000/api/screening/${flowData.screeningId}/medication',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "hypertensionDrugName": hyDrugController.text,
          "antidiabeticDrugName": dmDrugController.text,
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
