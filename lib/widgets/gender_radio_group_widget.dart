import 'package:flutter/material.dart';

enum Gender { male, female }

class GenderRadioGroupWidget extends StatelessWidget {
  const GenderRadioGroupWidget({
    super.key,
    this.value,
    required this.onChanged,
  });

  final Gender? value;
  final ValueChanged<Gender?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<Gender>(
      groupValue: value,
      onChanged: onChanged,
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
