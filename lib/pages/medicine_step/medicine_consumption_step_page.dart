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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Konsumsi Obat'),
          Form(
            key: formKey,
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Obat Hipertensi',
                    hintText: 'Amlodipine',
                  ),
                  controller: widget.delegate.hyDrugController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Obat Diabetes',
                    hintText: 'Metformin',
                  ),
                  controller: widget.delegate.dmDrugController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
