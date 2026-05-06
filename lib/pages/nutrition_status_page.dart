import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class NutritionStatusPage extends StatelessWidget {
  const NutritionStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  '18.0',
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
                      'Underweight',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                      textAlign: TextAlign.center,
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
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Tinggi Badan',
                  value: 168.toString(),
                  unit: 'cm',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Berat Badan',
                  value: 50.toString(),
                  unit: 'Kg',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Lingkar Perut',
                  value: 58.toString(),
                  unit: 'cm',
                ),
              ),
            ],
          ),
        ],
      ),
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
