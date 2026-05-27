import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/medicine_step/medicine_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class MedicineConsumptionStepPage extends StatefulWidget {
  const MedicineConsumptionStepPage({super.key, required this.delegate});

  final MedicineStepFlowDelegate delegate;

  @override
  State<MedicineConsumptionStepPage> createState() =>
      _MedicineConsumptionStepPageState();
}

class _MedicineConsumptionStepPageState
    extends State<MedicineConsumptionStepPage> {
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
            title: 'Konsumsi Obat',
            subtitle:
                'Masukkan obat yang sedang dikonsumsi agar rekomendasi lebih sesuai.',
          ),

          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: widget.delegate.hyDrugController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    label: 'Obat Hipertensi',
                    hint: 'Contoh: Amlodipine',
                    helper: 'Kosongkan jika tidak mengonsumsi obat hipertensi',
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.dmDrugController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: cleanInputDecoration(
                    label: 'Obat Diabetes',
                    hint: 'Contoh: Metformin',
                    helper: 'Kosongkan jika tidak mengonsumsi obat diabetes',
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
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
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
