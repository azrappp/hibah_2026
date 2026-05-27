import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/antropometric_step/antropometric_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class AntopometricStepPage extends StatefulWidget {
  const AntopometricStepPage({super.key, required this.delegate});

  final AntropometricStepFlowDelegate delegate;

  @override
  State<AntopometricStepPage> createState() => AntopometricStepPageState();
}

class AntopometricStepPageState extends State<AntopometricStepPage> {
  final formKey = GlobalKey<FormState>();

  static const Color healthGreen = Color(0xFF04C83A);
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
            title: 'Antropometri',
            subtitle:
                "Masukkan data tubuh Anda untuk menghitung status gizi dan kebutuhan energi harian.",
          ),

          const SizedBox(height: 8),

          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: widget.delegate.weightController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    context: context,
                    label: 'Berat Badan',
                    hint: 'Contoh: 68',
                    helper: 'Dalam satuan kilogram (kg)',
                    suffix: 'kg',
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.heightController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    context: context,
                    label: 'Tinggi Badan',
                    hint: 'Contoh: 160',
                    helper: 'Dalam satuan sentimeter (cm)',
                    suffix: 'cm',
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.waistController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: cleanInputDecoration(
                    context: context,
                    label: 'Lingkar Perut',
                    hint: 'Contoh: 84',
                    helper: 'Dalam satuan sentimeter (cm)',
                    suffix: 'cm',
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
    required BuildContext context,
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
