import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/card_widget.dart';

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
}

class ActivityRadioGroupWidget extends StatelessWidget {
  const ActivityRadioGroupWidget({
    super.key,
    this.value,
    required this.onChanged,
  });

  final Activity? value;
  final ValueChanged<Activity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<Activity>(
      groupValue: value,
      onChanged: onChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            spacing: 16.0,
            children: [
              CardWidget(
                padding: 0.0,
                color: value == Activity.veryLow
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  title: Text('Sangat Rendah'),
                  subtitle: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                  ),
                  trailing: Radio<Activity>(value: Activity.veryLow),
                ),
              ),
              CardWidget(
                padding: 0.0,
                color: value == Activity.low
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  title: Text('Rendah'),
                  subtitle: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                  ),
                  trailing: Radio<Activity>(value: Activity.low),
                ),
              ),
              CardWidget(
                padding: 0.0,
                color: value == Activity.medium
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  title: Text('Sedang'),
                  subtitle: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                  ),
                  trailing: Radio<Activity>(value: Activity.medium),
                ),
              ),
              CardWidget(
                padding: 0.0,
                color: value == Activity.high
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  title: Text('Tinggi'),
                  subtitle: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                  ),
                  trailing: Radio<Activity>(value: Activity.high),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
