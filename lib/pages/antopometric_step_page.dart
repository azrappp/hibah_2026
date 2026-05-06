import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class AntopometricStepPage extends StatelessWidget {
  const AntopometricStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Antopometri'),
          Form(
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Berat Badan',
                    hintText: '50',
                    helperText: 'Berat badan dalam satuan Kg',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tinggi Badan',
                    hintText: '169',
                    helperText: 'Tinggi badan dalam satuan cm',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Lingkar Perut',
                    hintText: '58',
                    helperText: 'Lingkar perut dalam satuan cm',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
