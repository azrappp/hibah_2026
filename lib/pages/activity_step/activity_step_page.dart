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
  static const Color healthGreen = Color(0xFF04C83A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FormHeader(
            title: 'Aktivitas Fisik',
            subtitle:
                'Pilih tingkat aktivitas harian untuk menghitung kebutuhan energi.',
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tingkat Aktivitas',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textMedium,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Theme(
                  data: Theme.of(context).copyWith(
                    radioTheme: RadioThemeData(
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return healthGreen;
                        }
                        return Colors.grey.shade400;
                      }),
                    ),
                  ),
                  child: ListenableBuilder(
                    listenable: widget.delegate,
                    builder: (context, _) {
                      return ActivityRadioGroupWidget(
                        value: widget.delegate.activity,
                        onChanged: (Activity? value) {
                          widget.delegate.setActivity(value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
