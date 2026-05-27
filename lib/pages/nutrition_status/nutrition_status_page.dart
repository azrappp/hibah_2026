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
  static const Color healthGreen = Color(0xFF04C83A);
  static const Color healthGreenSoft = Color(0xFFEAF8E9);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

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

        final bmi = formatValue(data?['bmi']);
        final bmiStatus = data?['bmiStatus']?.toString() ?? '-';
        final height = formatValue(data?['heightCm']);
        final weight = formatValue(data?['weightKg']);
        final waist = formatValue(data?['waistCircumferenceCm']);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FormHeader(
                title: 'Status Gizi',
                subtitle:
                    'Hasil perhitungan IMT digunakan untuk memantau kondisi gizi tubuh Anda.',
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderSoft, width: 1.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 18),

                    Text(
                      'IMT',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        bmi,
                        style: const TextStyle(
                          color: textDark,
                          fontFamily: 'GeistMono',
                          fontSize: 72.0,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: healthGreenSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        bmiStatus,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: healthGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      getBmiMessage(bmiStatus),
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
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'Tinggi\nBadan', // Added \n to force a line break
                      value: height,
                      unit: 'cm',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Berat\nBadan', // Added \n
                      value: weight,
                      unit: 'kg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Lingkar\nPerut', // Added \n
                      value: waist,
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

  String formatValue(dynamic value) {
    if (value == null) return '-';

    final number = double.tryParse(value.toString());
    if (number == null) return value.toString();

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }

  String getBmiMessage(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('normal')) {
      return 'Status gizi berada dalam rentang normal.';
    }

    if (normalized.contains('underweight') || normalized.contains('kurang')) {
      return 'Berat badan berada di bawah rentang ideal dan perlu diperhatikan.';
    }

    if (normalized.contains('overweight')) {
      return 'Berat badan berada di atas rentang ideal dan perlu dikendalikan.';
    }

    if (normalized.contains('obese') || normalized.contains('obesitas')) {
      return 'Berat badan cukup tinggi dan perlu pemantauan pola makan serta aktivitas.';
    }

    return 'Pantau status gizi secara berkala untuk menjaga kesehatan tubuh.';
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

  static const Color healthGreen = Color(0xFF04C83A);
  static const Color healthGreenSoft = Color(0xFFEAF8E9);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$value $unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textDark,
                fontFamily: 'GeistMono',
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
