import 'package:flutter/material.dart';

enum Gender { male, female }

class GenderRadioGroupWidget extends StatefulWidget {
  const GenderRadioGroupWidget({super.key});

  @override
  State<GenderRadioGroupWidget> createState() => _GenderRadioGroupWidgetState();
}

class _GenderRadioGroupWidgetState extends State<GenderRadioGroupWidget> {
  Gender? _gender = Gender.male;
  @override
  Widget build(BuildContext context) {
    return RadioGroup<Gender>(
      groupValue: _gender,
      onChanged: (Gender? value) => setState(() {
        _gender = value;
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Jenis Kelamin',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Laki-laki'),
                  leading: Radio<Gender>(value: Gender.male),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Perempuan'),
                  leading: Radio<Gender>(value: Gender.female),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
