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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Gula Darah'),
          Form(
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'FPG',
                    hintText: '88',
                    helperText: 'Gula darah puasa (mg/dL)',
                  ),
                  controller: widget.delegate.fpgController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '2-h PG',
                    hintText: '110',
                    helperText: 'Gula darah 2 jam setelah OGTT (mg/dL)',
                  ),
                  controller: widget.delegate.twoHPgController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Random PG',
                    hintText: '95',
                    helperText: 'Gula darah sewaktu (mg/dL)',
                  ),
                  controller: widget.delegate.randPgController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'A1C',
                    hintText: '5.2',
                    helperText: 'Rata-rata gula darah 2-3 bulan terakhir (%)',
                  ),
                  controller: widget.delegate.a1cController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
