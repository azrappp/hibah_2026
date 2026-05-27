import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/blood_sugar_step/blood_sugar_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class BloodSugarStepPage extends StatefulWidget {
  const BloodSugarStepPage({super.key, required this.delegate});

  final BloodSugarStepFlowDelegate delegate;

  @override
  State<BloodSugarStepPage> createState() => _BloodSugarStepPageState();
}

class _BloodSugarStepPageState extends State<BloodSugarStepPage> {
  final formKey = GlobalKey<FormState>();

  static const Color healthGreen = Color(0xFF04C83A);
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
            title: 'Gula Darah',
            subtitle:
                "Masukkan hasil pemeriksaan gula darah untuk menilai risiko diabetes",
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 28),

          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: widget.delegate.fpgController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    label: 'FPG',
                    hint: 'Contoh: 88',
                    helper: 'Gula darah puasa',
                    suffix: 'mg/dL',
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.twoHPgController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    label: '2-h PG',
                    hint: 'Contoh: 110',
                    helper: 'Gula darah 2 jam setelah OGTT',
                    suffix: 'mg/dL',
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.randPgController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    label: 'Random PG',
                    hint: 'Contoh: 95',
                    helper: 'Gula darah sewaktu',
                    suffix: 'mg/dL',
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.a1cController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: cleanInputDecoration(
                    label: 'A1C',
                    hint: 'Contoh: 5.2',
                    helper: 'Rata-rata gula darah 2–3 bulan terakhir',
                    suffix: '%',
                  ),
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
    required String helper,
    required String suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
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
      helperStyle: TextStyle(
        color: Colors.grey.shade500,
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
