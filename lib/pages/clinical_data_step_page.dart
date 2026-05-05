import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class ClinicalDataStepPage extends StatelessWidget {
  const ClinicalDataStepPage({super.key});

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
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Diastol',
                              hintText: '80',
                            ),
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
