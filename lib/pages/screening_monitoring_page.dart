import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/widgets/screening_progress_card.dart';
import 'package:hibah_2026/main.dart';
import 'package:hibah_2026/models/client_screening_history.dart';
import 'package:hibah_2026/pages/screening_page.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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

  static const Color healthGreen = Color(0xFF04C83A);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);

  @override
  void initState() {
    super.initState();
    fetchScreeningHistory();
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
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> startNewScreening() async {
    try {
      setState(() {
        isStartingScreening = true;
        errorMessage = null;
      });

      final response = await http.post(
        AppConfig.apiUri('/api/screening/${widget.clientId}/new-screening'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode != 201) {
        setState(() {
          errorMessage = 'Gagal membuat screening baru.';
        });
        return;
      }

      final body = jsonDecode(response.body);
      final screeningId = body['data']['screeningId'].toString();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => FlowController(
              clientId: widget.clientId,
              screeningId: screeningId,
              isRepeatScreening: true,
            ),
            child: const ScreeningPage(),
          ),
        ),
      );

      await fetchScreeningHistory();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isStartingScreening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = screeningHistory;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Monitoring Kesehatan',
          style: TextStyle(fontWeight: FontWeight.w900, color: textDark),
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

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: isStartingScreening ? null : startNewScreening,
                    label: Text(
                      isStartingScreening
                          ? 'Membuat Screening...'
                          : 'Screening Ulang',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: healthGreen,
                      disabledBackgroundColor: healthGreen.withValues(
                        alpha: 0.35,
                      ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Antropometri',
                  currentValue: getLastBmi(history),
                  unit: 'IMT',
                  status: 'Perkembangan IMT dan berat badan',
                  values: getBmiValues(history),
                  labels: getDateLabels(history),
                ),

                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Gula Darah',
                  currentValue: getLastGlucose(history),
                  unit: 'mg/dL',
                  status: 'Perkembangan kadar gula darah',
                  values: getGlucoseValues(history),
                  labels: getDateLabels(history),
                ),

                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Tekanan Darah',
                  currentValue: getLastBloodPressure(history),
                  unit: 'mmHg',
                  status: 'Perkembangan tekanan darah',
                  values: getSystolicValues(history),
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
}

class ClientHeaderCard extends StatelessWidget {
  const ClientHeaderCard({super.key, required this.history});

  final ClientScreeningHistory history;

  static const Color healthGreen = Color(0xFF04C83A);
  static const Color healthGreenSoft = Color(0xFFEAF8E9);
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
                    fontWeight: FontWeight.w900,
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
                Text(
                  history.totalScreenings.toString(),
                  style: const TextStyle(
                    color: healthGreen,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'GeistMono',
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Screening',
                  style: TextStyle(
                    color: healthGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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
}

class EmptyScreeningCard extends StatelessWidget {
  const EmptyScreeningCard({super.key});

  static const Color healthGreen = Color(0xFF04C83A);
  static const Color healthGreenSoft = Color(0xFFEAF8E9);
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
              fontWeight: FontWeight.w900,
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
