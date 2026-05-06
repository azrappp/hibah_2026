import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/nutrition_status_page.dart';
import 'package:hibah_2026/widgets/card_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class EnergyNeedsPage extends StatelessWidget {
  const EnergyNeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Kebutuhan Energi'),
          CardWidget(
            width: double.infinity,
            height: 398.0,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            padding: 24.0,
            child: Column(
              children: <Widget>[
                Text(
                  'Kalori Harian',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  '1850',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'GeistMono',
                    fontSize: 86.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Spacer(),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 16.0,
            children: <Widget>[
              Expanded(
                child: SummaryCard(
                  label: 'Karbohidrat',
                  value: 198.toString(),
                  unit: 'g',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Lemak',
                  value: 52.toString(),
                  unit: 'g',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Protein',
                  value: 122.toString(),
                  unit: 'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
