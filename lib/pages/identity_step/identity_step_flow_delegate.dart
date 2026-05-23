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

  void setGender(Gender? value) {
    gender = value ?? gender;
    notifyListeners();
  }

  @override
  bool get canGoBack => backable;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<ApiResponse> onNext() async {
    try {
      final fullName = nameController.text.trim();
      final age = int.tryParse(ageController.text.trim());
      final occupation = occupationController.text.trim();

      if (fullName.isEmpty) {
        debugPrint('Validation Error: fullName is required');
        return ApiResponse(success: false);
      }

      if (age == null || age <= 0) {
        debugPrint('Validation Error: valid age is required');
        return ApiResponse(success: false);
      }

      _isLoading = true;
      notifyListeners();

      final payload = {
        'fullName': fullName,
        'age': age,
        'gender': mapGenderToApi(gender),
        'occupation': occupation.isEmpty ? null : occupation,
      };

      debugPrint('Identity Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/screening/identity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final responseBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;

      if (response.statusCode == 201) {
        debugPrint('Identity Response: ${response.body}');

        flowData.clientId = responseBody['data']['clientId'].toString();

        return ApiResponse(success: true, data: responseBody);
      }

      debugPrint('HTTP Error: ${response.statusCode} - ${response.body}');

      return ApiResponse(success: false, data: responseBody);
    } catch (e) {
      debugPrint('Exception: $e');
      return ApiResponse(success: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String mapGenderToApi(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return 'laki-laki';
      case Gender.female:
        return 'perempuan';
      default:
        return 'laki-laki';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    occupationController.dispose();
    super.dispose();
  }
}
