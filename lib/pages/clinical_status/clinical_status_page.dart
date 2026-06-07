import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/clinical_status/clinical_status_flow_delegate.dart';
import 'package:hibah_2026/widgets/card_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class ClinicalStatusPage extends StatefulWidget {
  const ClinicalStatusPage({super.key, required this.delegate});

  final ClinicalStatusFlowDelegate delegate;

  @override
  State<ClinicalStatusPage> createState() => _ClinicalStatusPageState();
}

class _ClinicalStatusPageState extends State<ClinicalStatusPage> {
  static const Color healthGreen = Color(0xFF2F5D50);

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

        final hypertensionDiagnosis =
            data?['hypertension']?['diagnosis']?.toString() ?? '-';

        final diabetesDiagnosis =
            data?['diabetesMellitus']?['diagnosis']?.toString() ?? '-';

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FormHeader(
                title: 'Hasil Analisis Klinis',
                subtitle:
                    'Ringkasan hasil pemeriksaan untuk membantu memantau risiko kesehatan Anda.',
              ),

              const SizedBox(height: 24),

              ClinicalResultCard(
                title: 'Hipertensi',
                diagnosis: hypertensionDiagnosis,
                message: getHypertensionMessage(hypertensionDiagnosis),
                isNormal: isNormalStatus(hypertensionDiagnosis),
              ),

              const SizedBox(height: 16),

              ClinicalResultCard(
                title: 'Diabetes Melitus',
                diagnosis: diabetesDiagnosis,
                message: getDiabetesMessage(diabetesDiagnosis),
                isNormal: isNormalStatus(diabetesDiagnosis),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool isNormalStatus(String value) {
    final status = value.toLowerCase();
    return status.contains('normal') ||
        status.contains('tidak') ||
        status.contains('none');
  }

  static String getHypertensionMessage(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('normal')) {
      return 'Tekanan darah berada dalam rentang normal.';
    }

    if (normalized.contains('stage') ||
        normalized.contains('hypertension') ||
        normalized.contains('hipertensi')) {
      return 'Tekanan darah meningkat dan perlu dipantau secara rutin.';
    }

    return 'Pantau tekanan darah untuk menjaga kesehatan jantung.';
  }

  static String getDiabetesMessage(String status) {
    final normalized = status.toLowerCase();

    if (normalized.contains('normal')) {
      return 'Kadar gula darah berada dalam rentang normal.';
    }

    if (normalized.contains('prediabetes')) {
      return 'Kadar gula darah mulai meningkat dan perlu dikendalikan.';
    }

    if (normalized.contains('diabetes')) {
      return 'Kadar gula darah tinggi dan perlu tindak lanjut kesehatan.';
    }

    return 'Pantau gula darah secara berkala untuk menjaga kesehatan.';
  }
}

class ClinicalResultCard extends StatelessWidget {
  const ClinicalResultCard({
    super.key,
    required this.title,
    required this.diagnosis,
    required this.message,
    required this.isNormal,
  });

  final String title;
  final String diagnosis;
  final String message;
  final bool isNormal;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color warningSoft = Color(0xFFFFF4E5);
  static const Color warning = Color(0xFFE89B22);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isNormal ? healthGreen : warning;

    return CardWidget(
      padding: 22.0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            diagnosis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
