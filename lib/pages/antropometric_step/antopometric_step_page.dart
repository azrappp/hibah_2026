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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Antopometri'),
          Form(
            key: formKey,
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Berat Badan',
                    hintText: '50',
                    helperText: 'Berat badan dalam satuan Kg',
                  ),
                  controller: widget.delegate.weightController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tinggi Badan',
                    hintText: '169',
                    helperText: 'Tinggi badan dalam satuan cm',
                  ),
                  controller: widget.delegate.heightController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Lingkar Perut',
                    hintText: '58',
                    helperText: 'Lingkar perut dalam satuan cm',
                  ),
                  controller: widget.delegate.waistController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
