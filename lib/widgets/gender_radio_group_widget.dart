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

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textDark;
            }
            return textMedium;
          }),
        ),
      ),
      // 1. Add RadioGroup ancestor to manage the shared state
      child: RadioGroup<Gender>(
        groupValue: value,
        onChanged: onChanged,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Laki-laki',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                // 2. Remove groupValue and onChanged here
                leading: const Radio<Gender>(value: Gender.male),
                onTap: () => onChanged(Gender.male),
              ),
            ),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Perempuan',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                leading: const Radio<Gender>(value: Gender.female),
                onTap: () => onChanged(Gender.female),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
