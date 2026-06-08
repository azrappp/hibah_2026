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
  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

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
          return const Center(
            child: CircularProgressIndicator(color: healthGreen),
          );
        }

        final response = widget.delegate.apiResponse;
        final data = response?.data?['data'];

        final dailyEnergy = formatValue(data?['dailyEnergyKcal']);
        final carbohydrate = formatValue(data?['carbohydrateGram']);
        final fat = formatValue(data?['fatGram']);
        final protein = formatValue(data?['proteinGram']);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FormHeader(
                title: 'Kebutuhan Energi',
                subtitle:
                    'Estimasi kebutuhan energi harian berdasarkan data screening Anda.',
              ),

              const SizedBox(height: 24),

              CardWidget(
                width: double.infinity,
                color: Colors.white,
                padding: 24.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Kalori Harian',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        dailyEnergy,
                        style: const TextStyle(
                          color: healthGreen,
                          fontFamily: 'GeistMono',
                          fontSize: 72.0,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'kkal / hari',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Angka ini menjadi acuan untuk menyusun rekomendasi menu harian.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: <Widget>[
                  Expanded(
                    child: SummaryCard(
                      label: 'Karbohidrat',
                      value: carbohydrate,
                      unit: 'g',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(label: 'Lemak', value: fat, unit: 'g'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Protein',
                      value: protein,
                      unit: 'g',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: healthGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                  label: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatValue(dynamic value) {
    if (value == null) return '-';

    final number = double.tryParse(value.toString());
    if (number == null) return value.toString();

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}
