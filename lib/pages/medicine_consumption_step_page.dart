import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class MedicineConsumptionStepPage extends StatelessWidget {
  const MedicineConsumptionStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Konsumsi Obat'),
          Form(
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Obat Hipertensi',
                    hintText: 'Pilih Obat...',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Obat Diabetes',
                    hintText: 'Pilih Obat...',
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
