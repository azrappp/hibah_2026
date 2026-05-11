import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/nutrition_status/nutrition_status_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class NutritionStatusPage extends StatefulWidget {
  const NutritionStatusPage({super.key, required this.delegate});

  final NutritionStatusFlowDelegate delegate;

  @override
  State<NutritionStatusPage> createState() => _NutritionStatusPageState();
}

class _NutritionStatusPageState extends State<NutritionStatusPage> {
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
              FormHeader(title: 'Status Gizi'),
              Container(
                height: 398.0,
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'IMT',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${response?.data?['data']['bmi']}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'GeistMono',
                        fontSize: 86.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Column(
                      spacing: 8.0,
                      children: [
                        Text(
                          '${response?.data?['data']['bmiStatus']}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                          textAlign: TextAlign.center,
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
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'Tinggi Badan',
                      value: '${response?.data?['data']['heightCm']}',
                      unit: 'cm',
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      label: 'Berat Badan',
                      value: '${response?.data?['data']['weightKg']}',
                      unit: 'Kg',
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      label: 'Lingkar Perut',
                      value:
                          '${response?.data?['data']['waistCircumferenceCm']}',
                      unit: 'cm',
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

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        spacing: 24.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '$value $unit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'GeistMono',
              fontWeight: FontWeight.w600,
              letterSpacing: -1.5,
            ),
          ),
        ],
      ),
    );
  }
}
