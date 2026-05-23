import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/screening_progress_card.dart';
import 'dart:convert';
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
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  bool isLoading = false;
  bool isStartingScreening = false;
  String? errorMessage;

  ClientScreeningHistory? screeningHistory;

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
        Uri.parse('$baseUrl/clients/${widget.clientId}/screening-history'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          screeningHistory = ClientScreeningHistory.fromJson(body['data']);
        });
        return;
      }

      setState(() {
        errorMessage = 'Failed to load screening history';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
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
        Uri.parse('$baseUrl/screening/${widget.clientId}/new-screening'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        setState(() {
          errorMessage = 'Failed to create new screening';
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
            child: ScreeningPage(),
          ),
        ),
      );

      await fetchScreeningHistory();
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isStartingScreening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = screeningHistory;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Monitoring Kesehatan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF202124),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF202124),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchScreeningHistory,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (history == null)
                const EmptyScreeningCard()
              else ...[
                ClientHeaderCard(history: history),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: isStartingScreening ? null : startNewScreening,
                    icon: isStartingScreening
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_chart_rounded),
                    label: Text(
                      isStartingScreening
                          ? 'Membuat Screening...'
                          : 'Screening Ulang',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5E4AA0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (errorMessage != null) ...[
                  ErrorCard(message: errorMessage!),
                  const SizedBox(height: 16),
                ],

                ScreeningProgressCard(
                  title: 'Antropometri',
                  currentValue: getLastBmi(history),
                  unit: 'IMT',
                  status: 'Progress BMI dan berat badan',
                  values: getBmiValues(history),
                  labels: getDateLabels(history),
                  icon: Icons.monitor_weight_rounded,
                ),
                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Gula Darah',
                  currentValue: getLastGlucose(history),
                  unit: 'mg/dL',
                  status: 'Progress gula darah',
                  values: getGlucoseValues(history),
                  labels: getDateLabels(history),
                  icon: Icons.bloodtype_rounded,
                ),
                const SizedBox(height: 14),

                ScreeningProgressCard(
                  title: 'Tekanan Darah',
                  currentValue: getLastBloodPressure(history),
                  unit: 'mmHg',
                  status: 'Progress tekanan darah',
                  values: getSystolicValues(history),
                  labels: getDateLabels(history),
                  icon: Icons.favorite_rounded,
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

  @override
  Widget build(BuildContext context) {
    final client = history.client;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAF5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF5E4AA0),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  style: const TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${client.age} tahun • ${client.gender}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                history.totalScreenings.toString(),
                style: const TextStyle(
                  color: Color(0xFF5E4AA0),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Screening',
                style: TextStyle(
                  color: Color(0xFF5E4AA0),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyScreeningCard extends StatelessWidget {
  const EmptyScreeningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Belum ada data screening'));
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
