import 'package:flutter/material.dart';

enum Activity {
  veryLow,
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case Activity.veryLow:
        return 'Sangat Rendah';
      case Activity.low:
        return 'Rendah';
      case Activity.medium:
        return 'Sedang';
      case Activity.high:
        return 'Tinggi';
    }
  }

  String get description {
    switch (this) {
      case Activity.veryLow:
        return 'Sebagian besar waktu duduk dan jarang bergerak aktif.';
      case Activity.low:
        return 'Aktivitas ringan seperti berjalan santai atau pekerjaan rumah ringan.';
      case Activity.medium:
        return 'Aktivitas cukup aktif seperti berjalan rutin atau olahraga ringan.';
      case Activity.high:
        return 'Aktivitas berat atau olahraga rutin dengan intensitas tinggi.';
    }
  }

  IconData get icon {
    switch (this) {
      case Activity.veryLow:
        return Icons.chair_rounded;
      case Activity.low:
        return Icons.directions_walk_rounded;
      case Activity.medium:
        return Icons.directions_run_rounded;
      case Activity.high:
        return Icons.fitness_center_rounded;
    }
  }
}

class ActivityRadioGroupWidget extends StatelessWidget {
  const ActivityRadioGroupWidget({
    super.key,
    this.value,
    required this.onChanged,
  });

  final Activity? value;
  final ValueChanged<Activity?> onChanged;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return RadioGroup<Activity>(
      groupValue: value,
      onChanged: onChanged,
      child: Column(
        children: Activity.values.map((activity) {
          final isSelected = value == activity;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ActivityOptionCard(
              activity: activity,
              isSelected: isSelected,
              onTap: () => onChanged(activity),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ActivityOptionCard extends StatelessWidget {
  const ActivityOptionCard({
    super.key,
    required this.activity,
    required this.isSelected,
    required this.onTap,
  });

  final Activity activity;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? healthGreenSoft : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? healthGreen : borderSoft,
              width: isSelected ? 1.6 : 1.1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : healthGreenSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, color: healthGreen, size: 22),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      activity.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
