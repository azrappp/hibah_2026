import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/blood_sugar_step/blood_sugar_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';

class BloodSugarStepPage extends StatefulWidget {
  const BloodSugarStepPage({super.key, required this.delegate});

  final BloodSugarStepFlowDelegate delegate;

  @override
  State<BloodSugarStepPage> createState() => _BloodSugarStepPageState();
}

class _BloodSugarStepPageState extends State<BloodSugarStepPage> {
  final formKey = GlobalKey<FormState>();

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.delegate,
      builder: (context, _) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FormHeader(
                title: 'Gula Darah',
                subtitle:
                    'Pilih satu jenis pemeriksaan gula darah, lalu masukkan nilainya',
              ),

              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Jenis Pemeriksaan',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'TWO_HOUR',
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('2-h PG'),
                              ),
                            ),
                            ButtonSegment(
                              value: 'RANDOM',
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('Random'),
                              ),
                            ),
                            ButtonSegment(
                              value: 'FPG',
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('FPG'),
                              ),
                            ),
                            ButtonSegment(
                              value: 'HBA1C',
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('HbA1c'),
                              ),
                            ),
                          ],
                          selected: {widget.delegate.glucoseTestType},
                          onSelectionChanged: (selected) {
                            final value = selected.first;

                            widget.delegate.glucoseValueController.clear();
                            widget.delegate.setGlucoseTestType(value);
                          },
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            side: WidgetStateProperty.resolveWith<BorderSide>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return BorderSide(
                                  color: healthGreen.withValues(alpha: 0.55),
                                  width: 1.2,
                                );
                              }

                              return const BorderSide(
                                color: Color(0xFFE8E8E8),
                                width: 1.1,
                              );
                            }),
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return healthGreen.withValues(alpha: 0.10);
                                  }

                                  return Colors.white;
                                }),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return healthGreen;
                                  }

                                  return textMedium;
                                }),
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            visualDensity: VisualDensity.standard,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextFormField(
                      controller: widget.delegate.glucoseValueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: cleanInputDecoration(
                        label: widget.delegate.valueLabel,
                        hint: widget.delegate.valueHint,
                        helper: widget.delegate.valueHelper,
                        suffix: widget.delegate.valueSuffix,
                      ),
                    ),

                    if (widget.delegate.glucoseTestType == 'RANDOM') ...[
                      const SizedBox(height: 18),

                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: Color(0xFFE8E8E8),
                            width: 1.2,
                          ),
                        ),
                        child: SwitchListTile(
                          value: widget.delegate.hasClassicSymptoms,
                          onChanged: widget.delegate.setHasClassicSymptoms,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: const Text(
                            'Ada gejala diabetes?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textMedium,
                            ),
                          ),
                          subtitle: const Text(
                            'Misalnya sering haus, sering buang air kecil, atau sering lapar',
                          ),
                          activeThumbColor: healthGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration cleanInputDecoration({
    required String label,
    required String hint,
    required String helper,
    required String suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      suffixText: suffix.isEmpty ? null : suffix,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: textMedium,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
      suffixStyle: const TextStyle(
        color: healthGreen,
        fontWeight: FontWeight.w800,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: healthGreen, width: 1.6),
      ),
    );
  }
}
