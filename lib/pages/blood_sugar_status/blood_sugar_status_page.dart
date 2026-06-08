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

        final diagnosis = data?['diagnosis']?.toString() ?? '-';
        final glucoseTestType = data?['glucoseTestType']?.toString() ?? '-';
        final glucoseValue = formatValue(data?['glucoseValue']);
        final unit = getUnit(glucoseTestType);
        final testLabel = getGlucoseTestLabel(glucoseTestType);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FormHeader(
                title: 'Status Gula Darah',
                subtitle:
                    'Hasil pemeriksaan gula darah digunakan untuk menilai risiko diabetes.',
              ),

              const SizedBox(height: 24),

              CardWidget(
                padding: 22.0,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Diagnosis',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      diagnosis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: healthGreen,
                            letterSpacing: -0.4,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      getGlucoseMessage(diagnosis),
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

              SummaryCard(label: testLabel, value: glucoseValue, unit: unit),
            ],
          ),
        );
      },
    );
  }

  String formatValue(dynamic value) {
    if (value == null) return '-';

    final numberValue = num.tryParse(value.toString());

    if (numberValue == null) {
      return value.toString();
    }

    if (numberValue % 1 == 0) {
      return numberValue.toInt().toString();
    }

    return numberValue.toStringAsFixed(1);
  }

  String getUnit(String glucoseTestType) {
    if (glucoseTestType == 'HBA1C') {
      return '%';
    }

    return 'mg/dL';
  }

  String getGlucoseTestLabel(String glucoseTestType) {
    switch (glucoseTestType) {
      case 'FPG':
        return 'FPG';
      case 'TWO_HOUR':
        return '2-h PG';
      case 'RANDOM':
        return 'Random PG';
      case 'HBA1C':
        return 'HbA1c';
      default:
        return 'Pemeriksaan Gula Darah';
    }
  }

  String getGlucoseMessage(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('normal')) {
      return 'Kadar gula darah masih dalam rentang normal.';
    }

    if (normalized.contains('prediabetes')) {
      return 'Kadar gula darah mulai meningkat dan perlu dipantau.';
    }

    if (normalized.contains('diabetes')) {
      return 'Kadar gula darah tinggi dan perlu tindak lanjut kesehatan.';
    }

    if (normalized.contains('confirmation')) {
      return 'Hasil pemeriksaan memerlukan konfirmasi atau pemeriksaan lanjutan.';
    }

    if (normalized.contains('low')) {
      return 'Kadar gula darah rendah dan perlu diperhatikan.';
    }

    return 'Pantau hasil gula darah secara berkala untuk menjaga kesehatan.';
  }
}
