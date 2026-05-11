import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/blood_sugar_status/blood_sugar_status_flow_delegate.dart';
import 'package:hibah_2026/pages/nutrition_status/nutrition_status_page.dart';
import 'package:hibah_2026/widgets/card_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class BloodSugarStatusPage extends StatefulWidget {
  const BloodSugarStatusPage({super.key, required this.delegate});

  final BloodSugarStatusFlowDelegate delegate;

  @override
  State<BloodSugarStatusPage> createState() => _BloodSugarStatusPageState();
}

class _BloodSugarStatusPageState extends State<BloodSugarStatusPage> {
  @override
  void initState() {
    super.initState();
    widget.delegate.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.delegate,
      builder: (context, _) {
        if (widget.delegate.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final response = widget.delegate.apiResponse;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16.0,
            children: <Widget>[
              FormHeader(title: 'Status Gula Darah'),
              CardWidget(
                padding: 24.0,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  spacing: 48.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Diagnosa',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      spacing: 8.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${response?.data?['data']['glucoseStatus']}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Row(
                spacing: 16.0,
                children: <Widget>[
                  Expanded(
                    child: SummaryCard(
                      label: 'FPG',
                      value: '${response?.data?['data']['fastingGlucoseMgDl']}',
                      unit: 'mg/dL',
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      label: '2-h PG',
                      value:
                          '${response?.data?['data']['postprandialGlucoseMgDl']}',
                      unit: 'mg/dL',
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16.0,
                children: <Widget>[
                  Expanded(
                    child: SummaryCard(
                      label: 'Random PG',
                      value: '${response?.data?['data']['randomGlucoseMgDl']}',
                      unit: 'mg/dL',
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      label: 'A1C',
                      value: '${response?.data?['data']['hba1cPercent']}',
                      unit: '%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
