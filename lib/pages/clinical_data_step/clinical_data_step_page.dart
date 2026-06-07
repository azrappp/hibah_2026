import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/clinical_data_step/clinical_data_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class ClinicalDataStepPage extends StatefulWidget {
  const ClinicalDataStepPage({super.key, required this.delegate});

  final ClinicalDataStepFlowDelegate delegate;

  @override
  State<ClinicalDataStepPage> createState() => _ClinicalDataStepPageState();
}

class _ClinicalDataStepPageState extends State<ClinicalDataStepPage> {
  final formKey = GlobalKey<FormState>();

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FormHeader(
            title: 'Data Klinis',
            subtitle: "Masukkan tekanan darah untuk menilai risiko hipertensi",
          ),

          const SizedBox(height: 8),

          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tekanan Darah',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: widget.delegate.systolicController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: cleanInputDecoration(
                          label: 'Sistol',
                          hint: '120',
                          suffix: 'mmHg',
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: TextFormField(
                        controller: widget.delegate.diastolycController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: cleanInputDecoration(
                          label: 'Diastol',
                          hint: '80',
                          suffix: 'mmHg',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration cleanInputDecoration({
    required String label,
    required String hint,
    required String suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: textMedium,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
      ),
      suffixStyle: const TextStyle(
        color: healthGreen,
        fontWeight: FontWeight.w800,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: healthGreen, width: 1.6),
      ),
    );
  }
}
