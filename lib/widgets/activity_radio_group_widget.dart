import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/card_widget.dart';

enum Activity { veryLow, low, medium, high }

class ActivityRadioGroupWidget extends StatefulWidget {
  const ActivityRadioGroupWidget({super.key});

  @override
  State<ActivityRadioGroupWidget> createState() =>
      _ActivityRadioGroupWidgetState();
}

class _ActivityRadioGroupWidgetState extends State<ActivityRadioGroupWidget> {
  Activity? _activity = Activity.veryLow;
  @override
  Widget build(BuildContext context) {
    return RadioGroup<Activity>(
      groupValue: _activity,
      onChanged: (Activity? value) => setState(() {
        _activity = value;
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            spacing: 16.0,
            children: [
              CardWidget(
                padding: 0.0,
                color: _activity == Activity.veryLow
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
                color: _activity == Activity.low
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
                color: _activity == Activity.medium
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
                color: _activity == Activity.high
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
