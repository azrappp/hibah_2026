import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/main.dart';
import 'package:hibah_2026/widgets/gender_radio_group_widget.dart';

import 'package:http/http.dart' as http;

class IdentityStepFlowDelegate extends ChangeNotifier
    implements FlowStepDelegate {
  IdentityStepFlowDelegate({required this.backable, required this.flowData});

  final FlowData flowData;
  final bool backable;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final occupationController = TextEditingController();

  Gender? gender = Gender.male;
  bool _isLoading = false;

  void setGender(Gender? gender) {
    this.gender = gender ?? this.gender;
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
        Uri.parse('http://10.0.2.2:3000/api/screening/identity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': nameController.text,
          'age': ageController.text,
          'gender': gender.toString(),
          'occupation': occupationController.text,
        }),
      );
      if (response.statusCode == 201) {
        debugPrint(response.body);
        final mapResponse = jsonDecode(response.body);
        flowData.clientId = mapResponse['data']['clientId'].toString();
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
