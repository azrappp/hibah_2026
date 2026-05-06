import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';
import 'package:hibah_2026/widgets/gender_radio_group_widget.dart';

class IdentityStepPage extends StatelessWidget {
  const IdentityStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          FormHeader(title: 'Identitas Diri'),
          Form(
            child: Column(
              spacing: 32.0,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    hintText: 'John Doe',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usia',
                    hintText: '20',
                  ),
                ),
                GenderRadioGroupWidget(),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Pekerjaan',
                    hintText: 'Mahasiswa',
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
