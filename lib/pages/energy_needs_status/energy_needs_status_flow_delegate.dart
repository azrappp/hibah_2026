import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/main.dart';

import 'package:http/http.dart' as http;

class EnergyNeedsStatusFlowDelegate extends ChangeNotifier
    implements FlowStepDelegate {
  EnergyNeedsStatusFlowDelegate({
    required this.backable,
    required this.flowData,
  });

  final FlowData flowData;
  final bool backable;

  bool _isLoading = false;

  @override
  bool get canGoBack => backable;

  @override
  bool get isLoading => _isLoading;

  ApiResponse? apiResponse;

  Future<void> load() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/screening/${flowData.screeningId}/energy-requirement',
        ),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        debugPrint(response.body);
        final mapResponse = jsonDecode(response.body);
        apiResponse = ApiResponse(success: true, data: mapResponse);
        return;
      }

      debugPrint('HTTP Error: ${response.statusCode} - ${response.body}');
      apiResponse = ApiResponse(success: false);
      return;
    } catch (e) {
      debugPrint('Exception: $e');
      apiResponse = ApiResponse(success: false);
      return;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<ApiResponse> onNext() async {
    return apiResponse!;
  }
}
