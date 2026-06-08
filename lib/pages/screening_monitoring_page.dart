import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/widgets/screening_progress_card.dart';
import 'package:hibah_2026/main.dart';
import 'package:hibah_2026/models/client_screening_history.dart';
import 'package:hibah_2026/pages/screening_history/screening_history_list_page.dart';
import 'package:hibah_2026/pages/screening_page.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hibah_2026/widgets/mini_line_chart.dart';

class ScreeningMonitoringPage extends StatefulWidget {
  const ScreeningMonitoringPage({super.key, required this.clientId});

  final String clientId;

  @override
  State<ScreeningMonitoringPage> createState() =>
      _ScreeningMonitoringPageState();
}

class _ScreeningMonitoringPageState extends State<ScreeningMonitoringPage> {
  bool isLoading = false;
  bool isStartingScreening = false;
  String? errorMessage;

  ClientScreeningHistory? screeningHistory;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);

  @override
  void initState() {
    super.initState();
    fetchScreeningHistory();
  }

  Future<void> openScreeningList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScreeningHistoryListPage(clientId: widget.clientId),
      ),
    );

    await fetchScreeningHistory();
  }

  Future<void> fetchScreeningHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        AppConfig.apiUri('/api/clients/${widget.clientId}/screening-history'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        setState(() {
          screeningHistory = ClientScreeningHistory.fromJson(body['data']);
        });

        return;
      }

      setState(() {
        errorMessage = 'Gagal memuat riwayat screening.';
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

  String getLastWeight(ClientScreeningHistory history) {
    final values = history.chartData
        .map((item) => item.weightKg)
        .whereType<double>()
        .toList();

    if (values.isEmpty) return '-';

    return values.last.toStringAsFixed(0);
  }

  Future<void> startNewScreening() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FlowController(
            clientId: widget.clientId,
            screeningId: null,
            isRepeatScreening: true,
          ),
          child: const ScreeningPage(),
        ),
      ),
    );

    await fetchScreeningHistory();
  }

  List<ChartSeries> getWeightSeries(ClientScreeningHistory history) {
    return [
      ChartSeries(
        name: 'Berat',
        values: history.chartData.map((item) => item.weightKg).toList(),
        color: const Color(0xFF2F5D50),
      ),
    ];
  }

  List<ChartSeries> getBloodPressureSeries(ClientScreeningHistory history) {
    return [
      ChartSeries(
        name: 'Sistolik',
        values: history.chartData.map((item) => item.systolicBp).toList(),
        color: const Color(0xFF2F5D50),
      ),
      ChartSeries(
        name: 'Diastolik',
        values: history.chartData.map((item) => item.diastolicBp).toList(),
        color: const Color(0xFFB85C5C),
      ),
    ];
  }

  List<ChartSeries> getGlucoseSeries(ClientScreeningHistory history) {
    return [
      ChartSeries(
        name: 'FPG',
        values: history.chartData
            .map((item) => item.fastingGlucoseMgDl)
            .toList(),
        color: const Color(0xFF2F5D50),
      ),
      ChartSeries(
        name: '2-h PG',
        values: history.chartData
            .map((item) => item.postprandialGlucoseMgDl)
            .toList(),
        color: const Color(0xFFE89B22),
      ),
      ChartSeries(
        name: 'Random',
        values: history.chartData
            .map((item) => item.randomGlucoseMgDl)
            .toList(),
        color: const Color(0xFF5B6F95),
      ),
      ChartSeries(
        name: 'HbA1c',
        values: history.chartData.map((item) => item.hba1cPercent).toList(),
        color: const Color(0xFF8A5E9A),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final history = screeningHistory;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Monitoring Kesehatan',
          style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        foregroundColor: textDark,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchScreeningHistory,
          color: healthGreen,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: healthGreen),
                  ),
                )
              else if (history == null)
                const EmptyScreeningCard()
              else ...[
                ClientHeaderCard(history: history),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: TextButton(
                          onPressed: openScreeningList,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: healthGreen,
                            disabledForegroundColor: healthGreen.withValues(
                              alpha: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: const Text('Daftar Screening'),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: TextButton(
                          onPressed: isStartingScreening
                              ? null
                              : startNewScreening,
                          style: TextButton.styleFrom(
                            backgroundColor: healthGreen,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: healthGreen.withValues(
                              alpha: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(
                            isStartingScreening
                                ? 'Membuat...'
                                : 'Perbarui Data',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (errorMessage != null) ...[
                  ErrorCard(message: errorMessage!),
                  const SizedBox(height: 16),
                ],

                Text(
                  'Perkembangan Screening',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Berat Badan',
                  currentValue: getLastWeight(history),
                  unit: 'kg',
                  status: 'Riwayat berat badan berdasarkan screening',
                  finalStatus: getLastObesityStatus(history),
                  series: getWeightSeries(history),
                  labels: getDateLabels(history),
                ),

                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Gula Darah',
                  currentValue: getLastGlucose(history),
                  unit: 'mg/dL',
                  status: 'Riwayat pemeriksaan gula darah',
                  finalStatus: getLastDiabetesStatus(history),
                  series: getGlucoseSeries(history),
                  labels: getDateLabels(history),
                ),

                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Tekanan Darah',
                  currentValue: getLastBloodPressure(history),
                  unit: 'mmHg',
                  status: 'Riwayat sistolik dan diastolik',
                  finalStatus: getLastHypertensionStatus(history),
                  series: getBloodPressureSeries(history),
                  labels: getDateLabels(history),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> getDateLabels(ClientScreeningHistory history) {
    return history.chartData.map((item) => item.screeningDate).toList();
  }

  List<double> getBmiValues(ClientScreeningHistory history) {
    return history.chartData
        .map((item) => item.bmi)
        .whereType<double>()
        .toList();
  }

  List<double> getGlucoseValues(ClientScreeningHistory history) {
    return history.chartData
        .map(
          (item) =>
              item.fastingGlucoseMgDl ??
              item.randomGlucoseMgDl ??
              item.postprandialGlucoseMgDl,
        )
        .whereType<double>()
        .toList();
  }

  List<double> getSystolicValues(ClientScreeningHistory history) {
    return history.chartData
        .map((item) => item.systolicBp)
        .whereType<double>()
        .toList();
  }

  String getLastBmi(ClientScreeningHistory history) {
    final values = getBmiValues(history);
    if (values.isEmpty) return '-';
    return values.last.toStringAsFixed(1);
  }

  String getLastGlucose(ClientScreeningHistory history) {
    final values = getGlucoseValues(history);
    if (values.isEmpty) return '-';
    return values.last.toStringAsFixed(0);
  }

  String getLastBloodPressure(ClientScreeningHistory history) {
    final last = history.chartData.isEmpty ? null : history.chartData.last;

    if (last?.systolicBp == null || last?.diastolicBp == null) {
      return '-';
    }

    return '${last!.systolicBp!.toStringAsFixed(0)}/${last.diastolicBp!.toStringAsFixed(0)}';
  }

  ScreeningHistoryItem? getLastHistoryItem(ClientScreeningHistory history) {
    if (history.history.isEmpty) return null;
    return history.history.last;
  }

  String getLastObesityStatus(ClientScreeningHistory history) {
    final last = getLastHistoryItem(history);
    return last?.screeningResult.obesityStatus ?? '-';
  }

  String getLastDiabetesStatus(ClientScreeningHistory history) {
    final last = getLastHistoryItem(history);
    return last?.screeningResult.diabetesStatus ?? '-';
  }

  String getLastHypertensionStatus(ClientScreeningHistory history) {
    final last = getLastHistoryItem(history);
    return last?.screeningResult.hypertensionStatus ?? '-';
  }
}

class ClientHeaderCard extends StatelessWidget {
  const ClientHeaderCard({super.key, required this.history});

  final ClientScreeningHistory history;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final client = history.client;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Row(
        children: [
          GenderAvatar(gender: client.gender),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${client.age} tahun • ${client.gender}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: healthGreenSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Screening',
                  style: TextStyle(
                    color: healthGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  history.totalScreenings.toString(),
                  style: const TextStyle(
                    color: healthGreen,
                    fontSize: 16,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'GeistMono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GenderAvatar extends StatelessWidget {
  const GenderAvatar({super.key, required this.gender});

  final String? gender;

  String get assetPath {
    final normalized = gender?.toLowerCase().trim() ?? '';

    if (normalized == 'perempuan' ||
        normalized == 'female' ||
        normalized == 'wanita') {
      return 'assets/icons/female.svg';
    }

    return 'assets/icons/male.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: SvgPicture.asset(assetPath, fit: BoxFit.cover),
    );
  }

  List<ChartSeries> getWeightSeries(ClientScreeningHistory history) {
    return [
      ChartSeries(
        name: 'Berat',
        values: history.chartData.map((item) => item.weightKg).toList(),
        color: const Color(0xFF2F5D50),
      ),
    ];
  }

  List<ChartSeries> getBloodPressureSeries(ClientScreeningHistory history) {
    return [
      ChartSeries(
        name: 'Sistolik',
        values: history.chartData.map((item) => item.systolicBp).toList(),
        color: const Color(0xFF2F5D50),
      ),
      ChartSeries(
        name: 'Diastolik',
        values: history.chartData.map((item) => item.diastolicBp).toList(),
        color: const Color(0xFFB85C5C),
      ),
    ];
  }

  List<ChartSeries> getGlucoseSeries(ClientScreeningHistory history) {
    return [
      ChartSeries(
        name: 'FPG',
        values: history.chartData
            .map((item) => item.fastingGlucoseMgDl)
            .toList(),
        color: const Color(0xFF2F5D50),
      ),
      ChartSeries(
        name: '2-h PG',
        values: history.chartData
            .map((item) => item.postprandialGlucoseMgDl)
            .toList(),
        color: const Color(0xFFE89B22),
      ),
      ChartSeries(
        name: 'Random',
        values: history.chartData
            .map((item) => item.randomGlucoseMgDl)
            .toList(),
        color: const Color(0xFF5B6F95),
      ),
      ChartSeries(
        name: 'HbA1c',
        values: history.chartData.map((item) => item.hba1cPercent).toList(),
        color: const Color(0xFF8A5E9A),
      ),
    ];
  }
}

class EmptyScreeningCard extends StatelessWidget {
  const EmptyScreeningCard({super.key});

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: healthGreenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: healthGreen,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Belum ada data screening',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Mulai screening untuk memantau perkembangan kesehatan Anda.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  static const Color errorSoft = Color(0xFFFFECEC);
  static const Color error = Color(0xFFD84A4A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: errorSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
