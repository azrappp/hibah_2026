import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/energy_needs_status/energy_needs_status_flow_delegate.dart';
import 'package:hibah_2026/pages/nutrition_status/nutrition_status_page.dart';
import 'package:hibah_2026/widgets/card_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';
import 'package:hibah_2026/app_session.dart';
import 'package:provider/provider.dart';
import 'package:hibah_2026/pages/home_page.dart';

class EnergyNeedsPage extends StatefulWidget {
  const EnergyNeedsPage({super.key, required this.delegate});

  final EnergyNeedsStatusFlowDelegate delegate;

  @override
  State<EnergyNeedsPage> createState() => _EnergyNeedsPageState();
}

class _EnergyNeedsPageState extends State<EnergyNeedsPage> {
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

        return SingleChildScrollView(
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
                    const Spacer(),
                    Text(
                      '${response?.data?['data']['dailyEnergyKcal'] ?? '-'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'GeistMono',
                        fontSize: 86.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Kebutuhan energi harian dihitung berdasarkan data screening dan aktivitas fisik.',
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
                      value:
                          '${response?.data?['data']['carbohydrateGram'] ?? '-'}',
                      unit: 'g',
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      label: 'Lemak',
                      value: '${response?.data?['data']['fatGram'] ?? '-'}',
                      unit: 'g',
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      label: 'Protein',
                      value: '${response?.data?['data']['proteinGram'] ?? '-'}',
                      unit: 'g',
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    final flowData = widget.delegate.flowData;

                    debugPrint('clientId: ${flowData.clientId}');
                    debugPrint('screeningId: ${flowData.screeningId}');

                    if (flowData.clientId != null &&
                        flowData.screeningId != null) {
                      Provider.of<AppSession>(
                        context,
                        listen: false,
                      ).setFlowData(
                        clientId: flowData.clientId!,
                        screeningId: flowData.screeningId!,
                      );
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Selesai dan Kembali ke Home'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
