import 'package:flutter/material.dart';
import 'package:hibah_2026/api_response.dart';

enum StepType { result, form }

abstract class FlowStepDelegate {
  Future<ApiResponse> onNext();
  bool get canGoBack;
  bool get isLoading;
}

class FlowStep {
  final String id;
  final StepType type;
  final Widget page;
  final FlowStepDelegate delegate;

  FlowStep({
    required this.id,
    required this.type,
    required this.page,
    required this.delegate,
  });
}
