import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/main.dart';
import 'package:hibah_2026/widgets/activity_radio_group_widget.dart';

import 'package:http/http.dart' as http;

class ActivityStepFlowDelegate extends ChangeNotifier
    implements FlowStepDelegate {
  ActivityStepFlowDelegate({required this.backable, required this.flowData});

  final FlowData flowData;
  final bool backable;

  Activity? activity = Activity.veryLow;
  bool _isLoading = false;

  void setActivity(Activity? activity) {
    this.activity = activity ?? this.activity;
    notifyListeners();
  }

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
          'http://10.0.2.2:3000/api/screening/${flowData.screeningId}/physical-activity',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'activityLevel': activity?.label}),
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
