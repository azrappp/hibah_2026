import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/identity_step/identity_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';
import 'package:hibah_2026/widgets/gender_radio_group_widget.dart';

class IdentityStepPage extends StatefulWidget {
  const IdentityStepPage({super.key, required this.delegate});

  final IdentityStepFlowDelegate delegate;

  @override
  State<IdentityStepPage> createState() => IdentityStepPageState();
}

class IdentityStepPageState extends State<IdentityStepPage> {
  final formKey = GlobalKey<FormState>();

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
                  controller: widget.delegate.nameController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usia',
                    hintText: '20',
                  ),
                  controller: widget.delegate.ageController,
                ),
                ListenableBuilder(
                  listenable: widget.delegate,
                  builder: (context, _) {
                    return GenderRadioGroupWidget(
                      value: widget.delegate.gender,
                      onChanged: (Gender? value) {
                        widget.delegate.setGender(value);
                      },
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Pekerjaan',
                    hintText: 'Mahasiswa',
                  ),
                  controller: widget.delegate.occupationController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
