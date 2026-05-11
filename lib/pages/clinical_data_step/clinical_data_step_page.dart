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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Data Klinis'),
          Form(
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16.0,
                  children: <Widget>[
                    Text(
                      'Tekanan Darah',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      spacing: 16.0,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Sistol',
                              hintText: '120',
                            ),
                            controller: widget.delegate.systolicController,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Diastol',
                              hintText: '80',
                            ),
                            controller: widget.delegate.diastolycController,
                          ),
                        ),
                      ],
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
}
