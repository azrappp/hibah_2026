import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/clinical_status/clinical_status_flow_delegate.dart';
import 'package:hibah_2026/widgets/card_widget.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class ClinicalStatusPage extends StatefulWidget {
  const ClinicalStatusPage({super.key, required this.delegate});

  final ClinicalStatusFlowDelegate delegate;

  @override
  State<ClinicalStatusPage> createState() => _ClinicalStatusPageState();
}

class _ClinicalStatusPageState extends State<ClinicalStatusPage> {
  @override
  void initState() {
    super.initState();
    widget.delegate.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.delegate,
      builder: (context, _) {
        if (widget.delegate.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final response = widget.delegate.apiResponse;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16.0,
            children: <Widget>[
              FormHeader(title: 'Hasil Analisis Data\nKlinis'),
              CardWidget(
                padding: 24.0,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  spacing: 48.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hipertensi',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      spacing: 8.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${response?.data?['data']['hypertension']['diagnosis']}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CardWidget(
                padding: 24.0,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  spacing: 48.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Diabetes Melitus',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      spacing: 8.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${response?.data?['data']['diabetesMellitus']['diagnosis']}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
