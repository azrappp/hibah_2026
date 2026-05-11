import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/activity_step/activity_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/activity_radio_group_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class ActivityStepPage extends StatefulWidget {
  const ActivityStepPage({super.key, required this.delegate});

  final ActivityStepFlowDelegate delegate;

  @override
  State<ActivityStepPage> createState() => _ActivityStepPageState();
}

class _ActivityStepPageState extends State<ActivityStepPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Aktivitas Fisik'),
          ListenableBuilder(
            listenable: widget.delegate,
            builder: (context, _) {
              return ActivityRadioGroupWidget(
                value: widget.delegate.activity,
                onChanged: (Activity? value) =>
                    widget.delegate.setActivity(value),
              );
            },
          ),
        ],
      ),
    );
  }
}
