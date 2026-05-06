import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/nutrition_status_page.dart';
import 'package:hibah_2026/widgets/card_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class BloodSugarStatusPage extends StatelessWidget {
  const BloodSugarStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Normal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  value: 88.toString(),
                  unit: 'mg/dL',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: '2-h PG',
                  value: 110.toString(),
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
                  value: 95.toString(),
                  unit: 'mg/dL',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'A1C',
                  value: 5.2.toString(),
                  unit: '%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
