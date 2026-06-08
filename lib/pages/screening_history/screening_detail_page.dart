import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:http/http.dart' as http;

class ScreeningDetailPage extends StatefulWidget {
  const ScreeningDetailPage({super.key, required this.screeningId});

  final int screeningId;

  @override
  State<ScreeningDetailPage> createState() => _ScreeningDetailPageState();
}

class _ScreeningDetailPageState extends State<ScreeningDetailPage> {
  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? detail;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> deleteScreening() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.delete(
        AppConfig.apiUri('/api/screening/${widget.screeningId}'),
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        return;
      }

      setState(() {
        errorMessage = 'Gagal menghapus screening.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    }
    {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> confirmDeleteScreening() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Hapus Screening?',
            style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
          ),
          content: const Text(
            'Data screening ini akan dihapus permanen, termasuk hasil pemeriksaan dan rekomendasi menu yang terkait.',
            style: TextStyle(
              color: textMedium,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await deleteScreening();
  }

  Future<void> fetchDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        AppConfig.apiUri('/api/screening/${widget.screeningId}/detail'),
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        setState(() {
          detail = body['data'];
        });

        return;
      }

      setState(() {
        errorMessage = 'Gagal memuat detail screening.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = detail;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Detail Screening',
          style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        backgroundColor: background,
        surfaceTintColor: background,
        foregroundColor: textDark,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Hapus screening',
            onPressed: isLoading ? null : confirmDeleteScreening,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDetail,
          color: healthGreen,
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: healthGreen),
                );
              }

              if (errorMessage != null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _InfoCard(
                      title: 'Gagal Memuat Data',
                      message: errorMessage!,
                    ),
                  ],
                );
              }

              if (data == null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _InfoCard(
                      title: 'Data Tidak Tersedia',
                      message: 'Detail screening belum tersedia.',
                    ),
                  ],
                );
              }

              final client = data['client'];
              final anthropometry = data['anthropometryAssessment'];
              final biochemical = data['biochemicalAssessment'];
              final clinical = data['clinicalAssessment'];
              final activity = data['physicalActivityAssessment'];
              final energy = data['energyRequirement'];
              final result = data['screeningResult'];

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _HeaderCard(
                    title: client?['fullName']?.toString() ?? 'Klien',
                    subtitle: formatDate(parseDate(data['screeningDate'])),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Biodata',
                    children: [
                      _DetailRow(
                        label: 'Usia',
                        value: '${formatValue(client?['age'])} tahun',
                      ),
                      _DetailRow(
                        label: 'Jenis Kelamin',
                        value: formatGender(client?['gender']),
                      ),
                      _DetailRow(
                        label: 'Pekerjaan',
                        value: formatValue(client?['occupation']),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Hasil Screening',
                    children: [
                      _DetailRow(
                        label: 'Diabetes',
                        value: formatValue(result?['diabetesStatus']),
                        highlight: true,
                      ),
                      _DetailRow(
                        label: 'Hipertensi',
                        value: formatValue(result?['hypertensionStatus']),
                        highlight: true,
                      ),
                      _DetailRow(
                        label: 'Obesitas',
                        value: formatValue(result?['obesityStatus']),
                        highlight: true,
                      ),
                      if (result?['referralRequired'] == true)
                        _DetailRow(
                          label: 'Rujukan',
                          value: formatValue(result?['referralReason']),
                          highlight: true,
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Antropometri',
                    children: [
                      _DetailRow(
                        label: 'Berat Badan',
                        value: '${formatNumber(anthropometry?['weightKg'])} kg',
                      ),
                      _DetailRow(
                        label: 'Tinggi Badan',
                        value: '${formatNumber(anthropometry?['heightCm'])} cm',
                      ),
                      _DetailRow(
                        label: 'IMT',
                        value:
                            '${formatNumber(anthropometry?['bmi'])} (${formatValue(anthropometry?['bmiStatus'])})',
                      ),
                      _DetailRow(
                        label: 'Lingkar Perut',
                        value:
                            '${formatNumber(anthropometry?['waistCircumferenceCm'])} cm (${formatValue(anthropometry?['waistStatus'])})',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Gula Darah',
                    children: buildBloodSugarRows(biochemical),
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Tekanan Darah',
                    children: [
                      _DetailRow(
                        label: 'Tekanan Darah',
                        value:
                            '${formatNumber(clinical?['systolicBp'])}/${formatNumber(clinical?['diastolicBp'])} mmHg',
                      ),
                      _DetailRow(
                        label: 'Status',
                        value: formatValue(clinical?['bloodPressureStatus']),
                        highlight: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Aktivitas dan Kebutuhan Energi',
                    children: [
                      _DetailRow(
                        label: 'Aktivitas',
                        value: formatValue(activity?['activityLevel']),
                      ),
                      _DetailRow(
                        label: 'Energi Harian',
                        value:
                            '${formatNumber(energy?['dailyEnergyKcal'])} kkal',
                        highlight: true,
                      ),
                      _DetailRow(
                        label: 'Karbohidrat',
                        value: '${formatNumber(energy?['carbohydrateGram'])} g',
                      ),
                      _DetailRow(
                        label: 'Protein',
                        value: '${formatNumber(energy?['proteinGram'])} g',
                      ),
                      _DetailRow(
                        label: 'Lemak',
                        value: '${formatNumber(energy?['fatGram'])} g',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> buildBloodSugarRows(dynamic biochemical) {
    if (biochemical == null) {
      return const [_DetailRow(label: 'Pemeriksaan', value: '-')];
    }

    final fasting = biochemical['fastingGlucoseMgDl'];
    final twoHour = biochemical['postprandialGlucoseMgDl'];
    final random = biochemical['randomGlucoseMgDl'];
    final hba1c = biochemical['hba1cPercent'];

    if (fasting != null) {
      return [
        _DetailRow(label: 'FPG', value: '${formatNumber(fasting)} mg/dL'),
        _DetailRow(
          label: 'Status',
          value: formatValue(biochemical['glucoseStatus']),
          highlight: true,
        ),
      ];
    }

    if (twoHour != null) {
      return [
        _DetailRow(label: '2-h PG', value: '${formatNumber(twoHour)} mg/dL'),
        _DetailRow(
          label: 'Status',
          value: formatValue(biochemical['glucoseStatus']),
          highlight: true,
        ),
      ];
    }

    if (random != null) {
      return [
        _DetailRow(label: 'Random PG', value: '${formatNumber(random)} mg/dL'),
        _DetailRow(
          label: 'Status',
          value: formatValue(biochemical['glucoseStatus']),
          highlight: true,
        ),
      ];
    }

    if (hba1c != null) {
      return [
        _DetailRow(label: 'HbA1c', value: '${formatNumber(hba1c)}%'),
        _DetailRow(
          label: 'Status',
          value: formatValue(biochemical['hba1cStatus']),
          highlight: true,
        ),
      ];
    }

    return const [_DetailRow(label: 'Pemeriksaan', value: '-')];
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';

    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = dayNames[date.weekday - 1];
    final day = date.day;
    final monthName = monthNames[date.month - 1];
    final year = date.year;

    return '$dayName, $day $monthName $year';
  }

  static String formatGender(dynamic value) {
    final text = value?.toString().toLowerCase() ?? '';

    if (text.contains('male') || text.contains('laki')) {
      return 'Laki-laki';
    }

    if (text.contains('female') || text.contains('perempuan')) {
      return 'Perempuan';
    }

    return '-';
  }

  static String formatValue(dynamic value) {
    if (value == null) return '-';
    final text = value.toString();
    if (text.trim().isEmpty) return '-';
    return text;
  }

  static String formatNumber(dynamic value) {
    if (value == null) return '-';

    final number = num.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  static const Color textDark = Color(0xFF25262A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  static const Color healthGreen = Color(0xFF25262A);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textMedium,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 10,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highlight ? healthGreen : textDark,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
