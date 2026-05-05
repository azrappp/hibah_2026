import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/activity_radio_group_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class ActivityStepPage extends StatelessWidget {
  const ActivityStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Aktivitas Fisik'),
          ActivityRadioGroupWidget(),
        ],
      ),
    );
  }
}
